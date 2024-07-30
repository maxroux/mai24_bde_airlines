from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.hooks.base import BaseHook
from datetime import datetime, timedelta
import os
import requests
import json
import time
import random
from pymongo import MongoClient, UpdateOne
import psycopg2
from psycopg2.extras import execute_batch
from api_payload import get_access_token
import csv 

# Configuration par défaut du DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 7, 22),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Déclaration du DAG
dag = DAG(
    'fetch_countries_data_dag',
    default_args=default_args,
    description='DAG pour récupérer les détails des pays et les stocker dans MongoDB et PostgreSQL',
    schedule_interval=timedelta(days=30),
    catchup=False,
    tags=['api', 'etl']
)

# Fonction pour récupérer les détails des pays depuis l'API Lufthansa
def fetch_country_details(**kwargs):
    access_token = get_access_token()
    limit = kwargs.get('limit', 100)
    offset = kwargs.get('offset', 0)
    
    url = "https://api.lufthansa.com/v1/mds-references/countries"
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Accept": "application/json"
    }
    params = {
        "limit": limit,
        "offset": offset,
        "lang": "en"
    }

    all_countries = []

    while True:
        response = requests.get(url, headers=headers, params=params)
        response.raise_for_status()
        data = response.json()
        countries = data['CountryResource']['Countries']['Country']
        all_countries.extend(countries)

        # Vérifie si le nombre de résultats est inférieur à la limite, ce qui indique la fin des données disponibles
        if len(countries) < limit:
            break
        
        # Incrémentation de l'offset pour récupérer la page suivante
        offset += limit
        params['offset'] = offset

    return {"CountryResource": {"Countries": {"Country": all_countries}}}

# Fonction pour insérer les données dans MongoDB
def insert_to_mongo(**context):
    data = context['ti'].xcom_pull(task_ids='fetch_country_data')
    mongo_conn = BaseHook.get_connection('api_calls_mongodb')
    client = MongoClient(mongo_conn.host, mongo_conn.port, username=mongo_conn.login, password=mongo_conn.password)
    db = client['airline_project']
    collection = db['countries']

    operations = []
    for country in data['CountryResource']['Countries']['Country']:
        operations.append(
            UpdateOne(
                {'CountryCode': country['CountryCode']},
                {'$set': country},
                upsert=True
            )
        )
    if operations:
        result = collection.bulk_write(operations)
        upserted_count = result.upserted_count
        modified_count = result.modified_count
        print(f"Upserted: {upserted_count}, Modified: {modified_count}")
        # Retourner seulement des types sérialisables
        return {"upserted_count": upserted_count, "modified_count": modified_count}
    return {"upserted_count": 0, "modified_count": 0}

# Fonction pour insérer les données dans PostgreSQL
def insert_to_postgres(**context):
    data = context['ti'].xcom_pull(task_ids='fetch_country_data')
    postgres_conn = BaseHook.get_connection('api_calls_postgres')
    conn = psycopg2.connect(
        dbname=postgres_conn.schema,
        user=postgres_conn.login,
        password=postgres_conn.password,
        host=postgres_conn.host,
        port=postgres_conn.port
    )

    create_table_query = """
    CREATE TABLE IF NOT EXISTS countries (
        CountryCode VARCHAR(10) PRIMARY KEY,
        Names TEXT
    );
    """
    insert_query = """
    INSERT INTO countries (CountryCode, Names)
    VALUES (%s, %s)
    ON CONFLICT (CountryCode) DO UPDATE SET
        Names = EXCLUDED.Names;
    """
    data_to_insert = [
        (
            country['CountryCode'],
            ', '.join([name['$'] for name in country['Names']['Name']]) if isinstance(country['Names']['Name'], list) else country['Names']['Name']['$']
        )
        for country in data['CountryResource']['Countries']['Country']
    ]
    with conn.cursor() as cursor:
        cursor.execute(create_table_query)
        execute_batch(cursor, insert_query, data_to_insert)
    conn.commit()
    conn.close()
    return len(data)

# Fonction pour exporter les données en JSON
def export_to_json(**context):
    data = context['ti'].xcom_pull(task_ids='fetch_country_data')
    unique_countries = []
    seen = set()
    for country in data['CountryResource']['Countries']['Country']:
        if country['CountryCode'] not in seen:
            seen.add(country['CountryCode'])
            unique_countries.append(country)
    
    json_filename = '/opt/airflow/data/json/countries.json'
    os.makedirs(os.path.dirname(json_filename), exist_ok=True)
    with open(json_filename, 'w') as json_file:
        json.dump({"CountryResource": {"Countries": {"Country": unique_countries}}}, json_file, indent=4)
# Fonction pour exporter les données de JSON vers CSV
def export_to_csv(**context):
    json_filename = '/opt/airflow/data/json/countries.json'
    csv_filename = '/opt/airflow/data/csv/countries.csv'
    os.makedirs(os.path.dirname(csv_filename), exist_ok=True)
    with open(json_filename, 'r') as json_file:
        data = json.load(json_file)
    
    unique_countries = []
    seen = set()
    for item in data['CountryResource']['Countries']['Country']:
        if item['CountryCode'] not in seen:
            seen.add(item['CountryCode'])
            unique_countries.append(item)

    with open(csv_filename, 'w', newline='') as csv_file:
        fieldnames = ["CountryCode", "Names"]
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writeheader()
        for item in unique_countries:
            writer.writerow({
                "CountryCode": item['CountryCode'],
                "Names": ', '.join([name['$'] for name in item['Names']['Name']]) if isinstance(item['Names']['Name'], list) else item['Names']['Name']['$']
            })

# Définition des tâches Airflow
fetch_country_data_task = PythonOperator(
    task_id='fetch_country_data',
    python_callable=fetch_country_details,
    op_kwargs={'limit': 100, 'offset': 0},
    provide_context=True,
    dag=dag,
)

insert_to_mongo_task = PythonOperator(
    task_id='insert_to_mongo',
    python_callable=insert_to_mongo,
    provide_context=True,
    dag=dag,
)

insert_to_postgres_task = PythonOperator(
    task_id='insert_to_postgres',
    python_callable=insert_to_postgres,
    provide_context=True,
    dag=dag,
)

export_to_json_task = PythonOperator(
    task_id='export_to_json',
    python_callable=export_to_json,
    provide_context=True,
    dag=dag,
)

export_to_csv_task = PythonOperator(
    task_id='export_to_csv',
    python_callable=export_to_csv,
    provide_context=True,
    dag=dag,
)

# Définition de l'ordre d'exécution des tâches
fetch_country_data_task >> [insert_to_mongo_task, insert_to_postgres_task] >> export_to_json_task >> export_to_csv_task