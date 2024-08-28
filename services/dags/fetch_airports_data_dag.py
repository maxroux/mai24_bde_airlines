from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.hooks.base import BaseHook
from datetime import datetime, timedelta
import os
import requests
import json
import csv
import time
from pymongo import MongoClient, UpdateOne
import psycopg2
from psycopg2.extras import execute_batch
from api_payload import get_access_token
from airflow.operators.dagrun_operator import TriggerDagRunOperator

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
    'fetch_airports_data_dag',
    default_args=default_args,
    description='DAG pour récupérer les détails des aéroports et les stocker dans MongoDB et PostgreSQL',
    schedule_interval=timedelta(days=30),
    catchup=False,
    tags=['api', 'etl']
)

# Fonction pour récupérer toutes les pages de données d'aéroports
def fetch_all_airport_details(**kwargs):
    access_token = get_access_token()
    limit = 100
    offset = 0
    all_data = []

    while True:
        url = "https://api.lufthansa.com/v1/references/airports"
        headers = {
            "Authorization": f"Bearer {access_token}",
            "Accept": "application/json"
        }
        params = {
            "limit": limit,
            "offset": offset,
            "lang": "en"
        }
        response = requests.get(url, headers=headers, params=params)
        response.raise_for_status()
        data = response.json()
        all_data.extend(data['AirportResource']['Airports']['Airport'])
        
        if len(data['AirportResource']['Airports']['Airport']) < limit:
            break
        offset += limit

    return {"AirportResource": {"Airports": {"Airport": all_data}}}

# Fonction pour insérer les données dans MongoDB
def insert_to_mongo(**context):
    data = context['ti'].xcom_pull(task_ids='fetch_all_airport_data')
    mongo_conn = BaseHook.get_connection('api_calls_mongodb')
    client = MongoClient(mongo_conn.host, mongo_conn.port, username=mongo_conn.login, password=mongo_conn.password)
    db = client['airline_project']
    collection = db['airports']

    operations = []
    for airport in data['AirportResource']['Airports']['Airport']:
        operations.append(
            UpdateOne(
                {'AirportCode': airport['AirportCode']},
                {'$set': airport},
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

# Fonction pour insérer les données dans PostgreSQL
def insert_to_postgres(**context):
    data = context['ti'].xcom_pull(task_ids='fetch_all_airport_data')
    postgres_conn = BaseHook.get_connection('api_calls_postgres')
    conn = psycopg2.connect(
        dbname=postgres_conn.schema,
        user=postgres_conn.login,
        password=postgres_conn.password,
        host=postgres_conn.host,
        port=postgres_conn.port
    )

    create_table_query = """
    CREATE TABLE IF NOT EXISTS airports (
        AirportCode VARCHAR(10) PRIMARY KEY,
        CityCode VARCHAR(10),
        CountryCode VARCHAR(10),
        LocationType VARCHAR(50),
        Latitude DOUBLE PRECISION,
        Longitude DOUBLE PRECISION,
        TimeZoneId VARCHAR(50),
        UtcOffset VARCHAR(10),
        Names TEXT
    );
    """
    insert_query = """
    INSERT INTO airports (AirportCode, CityCode, CountryCode, LocationType, Latitude, Longitude, TimeZoneId, UtcOffset, Names)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
    ON CONFLICT (AirportCode) DO UPDATE SET
        CityCode = EXCLUDED.CityCode,
        CountryCode = EXCLUDED.CountryCode,
        LocationType = EXCLUDED.LocationType,
        Latitude = EXCLUDED.Latitude,
        Longitude = EXCLUDED.Longitude,
        TimeZoneId = EXCLUDED.TimeZoneId,
        UtcOffset = EXCLUDED.UtcOffset,
        Names = EXCLUDED.Names;
    """
    data_to_insert = [
        (
            airport['AirportCode'],
            airport.get('CityCode', ''),
            airport.get('CountryCode', ''),
            airport.get('LocationType', ''),
            airport['Position']['Coordinate'].get('Latitude', None),
            airport['Position']['Coordinate'].get('Longitude', None),
            airport.get('TimeZoneId', ''),
            airport.get('UtcOffset', ''),
            ', '.join([name['$'] for name in airport['Names']['Name']]) if isinstance(airport['Names']['Name'], list) else airport['Names']['Name']['$']
        )
        for airport in data['AirportResource']['Airports']['Airport']
    ]
    with conn.cursor() as cursor:
        cursor.execute(create_table_query)
        execute_batch(cursor, insert_query, data_to_insert)
    conn.commit()
    conn.close()
    return len(data)

# Fonction pour exporter les données en JSON
def export_to_json(**context):
    data = context['ti'].xcom_pull(task_ids='fetch_all_airport_data')
    unique_airports = []
    seen = set()
    for airport in data['AirportResource']['Airports']['Airport']:
        if airport['AirportCode'] not in seen:
            seen.add(airport['AirportCode'])
            unique_airports.append(airport)
    
    json_filename = '/opt/airflow/data/json/airports.json'
    os.makedirs(os.path.dirname(json_filename), exist_ok=True)
    with open(json_filename, 'w') as json_file:
        json.dump({"AirportResource": {"Airports": {"Airport": unique_airports}}}, json_file, indent=4)


# Fonction pour exporter les données de JSON vers CSV
def export_to_csv(**context):
    json_filename = '/opt/airflow/data/json/airports.json'
    csv_filename = '/opt/airflow/data/csv/airports.csv'
    os.makedirs(os.path.dirname(csv_filename), exist_ok=True)
    with open(json_filename, 'r') as json_file:
        data = json.load(json_file)
    
    unique_airports = []
    seen = set()
    for item in data['AirportResource']['Airports']['Airport']:
        if item['AirportCode'] not in seen:
            seen.add(item['AirportCode'])
            unique_airports.append(item)

    with open(csv_filename, 'w', newline='') as csv_file:
        fieldnames = ["AirportCode", "CityCode", "CountryCode", "LocationType", "Latitude", "Longitude", "TimeZoneId", "UtcOffset", "Names"]
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writeheader()
        for item in unique_airports:
            writer.writerow({
                "AirportCode": item['AirportCode'],
                "CityCode": item.get('CityCode', ''),
                "CountryCode": item.get('CountryCode', ''),
                "LocationType": item.get('LocationType', ''),
                "Latitude": item['Position']['Coordinate'].get('Latitude', ''),
                "Longitude": item['Position']['Coordinate'].get('Longitude', ''),
                "TimeZoneId": item.get('TimeZoneId', ''),
                "UtcOffset": item.get('UtcOffset', ''),
                "Names": ', '.join([name['$'] for name in item['Names']['Name']]) if isinstance(item['Names']['Name'], list) else item['Names']['Name']['$']
            })

# Définition des tâches Airflow
fetch_all_airport_data_task = PythonOperator(
    task_id='fetch_all_airport_data',
    python_callable=fetch_all_airport_details,
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
trigger_process_airport_flight_data_dag_task = TriggerDagRunOperator(
    task_id='trigger_process_airport_flight_data_dag',
    trigger_dag_id='process_airport_flight_data',
    dag=dag,
    trigger_rule='all_success'
)
# Définition de l'ordre d'exécution des tâches
fetch_all_airport_data_task >> [insert_to_mongo_task, insert_to_postgres_task] >> export_to_json_task >> export_to_csv_task >> trigger_process_airport_flight_data_dag_task
