from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.hooks.base import BaseHook
from datetime import datetime, timedelta
import os
import requests
import json
import time
import random
import csv
from pymongo import MongoClient, UpdateOne
import psycopg2
from psycopg2.extras import execute_batch
from api_payload import get_access_token

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 7, 22),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'fetch_airlines_data_dag',
    default_args=default_args,
    description='DAG pour récupérer les détails des compagnies aériennes et les stocker dans MongoDB et PostgreSQL',
    schedule_interval=timedelta(days=7),
    catchup=False,
    tags=['api', 'etl']
)

def fetch_airline_details(**kwargs):
    access_token = get_access_token()
    limit = kwargs.get('limit', 100)
    offset = kwargs.get('offset', 0)
    
    url = "https://api.lufthansa.com/v1/references/airlines"
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Accept": "application/json"
    }
    params = {
        "limit": limit,
        "offset": offset,
        "lang": "en"
    }

    all_airlines = []

    while True:
        response = requests.get(url, headers=headers, params=params)
        response.raise_for_status()
        data = response.json()
        airlines = data['AirlineResource']['Airlines']['Airline']
        all_airlines.extend(airlines)

        # Si le nombre de résultats retournés est inférieur à la limite, fin de pagination
        if len(airlines) < limit:
            break
        
        # Incrémentation de l'offset pour la page suivante
        offset += limit
        params['offset'] = offset

    return {"AirlineResource": {"Airlines": {"Airline": all_airlines}}}

def insert_to_mongo(**context):
    data = context['ti'].xcom_pull(task_ids='fetch_airline_data')
    mongo_conn = BaseHook.get_connection('api_calls_mongodb')
    client = MongoClient(mongo_conn.host, mongo_conn.port, username=mongo_conn.login, password=mongo_conn.password)
    db = client['airline_project']
    collection = db['airlines']

    operations = []
    for airline in data['AirlineResource']['Airlines']['Airline']:
        operations.append(
            UpdateOne(
                {'AirlineID': airline['AirlineID']},
                {'$set': airline},
                upsert=True
            )
        )
    if operations:
        result = collection.bulk_write(operations)
        upserted_count = result.upserted_count
        modified_count = result.modified_count
        print(f"Upserted: {upserted_count}, Modified: {modified_count}")
        return {"upserted_count": upserted_count, "modified_count": modified_count}
    return {"upserted_count": 0, "modified_count": 0}


def insert_to_postgres(**context):
    data = context['ti'].xcom_pull(task_ids='fetch_airline_data')
    postgres_conn = BaseHook.get_connection('api_calls_postgres')
    conn = psycopg2.connect(
        dbname=postgres_conn.schema,
        user=postgres_conn.login,
        password=postgres_conn.password,
        host=postgres_conn.host,
        port=postgres_conn.port
    )

    create_table_query = """
    CREATE TABLE IF NOT EXISTS airlines (
        AirlineID VARCHAR(10) PRIMARY KEY,
        Name TEXT
    );
    """
    insert_query = """
    INSERT INTO airlines (AirlineID, Name)
    VALUES (%s, %s)
    ON CONFLICT (AirlineID) DO UPDATE SET
        Name = EXCLUDED.Name;
    """
    data_to_insert = [
        (
            airline['AirlineID'],
            airline['Names']['Name']['$'] if isinstance(airline['Names']['Name'], dict) else ''
        )
        for airline in data['AirlineResource']['Airlines']['Airline']
    ]
    with conn.cursor() as cursor:
        cursor.execute(create_table_query)
        execute_batch(cursor, insert_query, data_to_insert)
    conn.commit()
    conn.close()
    return len(data)

def export_to_json(**context):
    data = context['ti'].xcom_pull(task_ids='fetch_airline_data')
    json_filename = '/opt/airflow/data/json/airlines.json'
    os.makedirs(os.path.dirname(json_filename), exist_ok=True)
    with open(json_filename, 'w') as json_file:
        json.dump(data, json_file, indent=4)

def export_to_csv(**context):
    json_filename = '/opt/airflow/data/json/airlines.json'
    csv_filename = '/opt/airflow/data/csv/airlines.csv'
    os.makedirs(os.path.dirname(csv_filename), exist_ok=True)
    with open(json_filename, 'r') as json_file:
        data = json.load(json_file)
    
    with open(csv_filename, 'w', newline='') as csv_file:
        fieldnames = ["AirlineID", "Name"]
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writeheader()
        for item in data['AirlineResource']['Airlines']['Airline']:
            writer.writerow({
                "AirlineID": item['AirlineID'],
                "Name": item['Names']['Name']['$'] if isinstance(item['Names']['Name'], dict) else ''
            })

fetch_airline_data_task = PythonOperator(
    task_id='fetch_airline_data',
    python_callable=fetch_airline_details,
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

fetch_airline_data_task >> [insert_to_mongo_task, insert_to_postgres_task] >> export_to_json_task >> export_to_csv_task
