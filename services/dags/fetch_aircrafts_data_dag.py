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
import smtplib

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 7, 22),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'fetch_aircrafts_data_dag',
    default_args=default_args,
    description='DAG pour récupérer les détails des avions et les stocker dans MongoDB et PostgreSQL',
    schedule_interval=timedelta(days=7),
    catchup=False,
    tags=['api', 'etl']
)

def fetch_aircraft_details(access_token, limit=100, offset=0):
    url = f"https://api.lufthansa.com/v1/mds-references/aircraft?limit={limit}&offset={offset}&languageCode=EN"
    headers = {"Authorization": f"Bearer {access_token}"}
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.json(), None
    else:
        return None, {
            "status_code": response.status_code,
            "reason": response.reason
        }

def insert_to_mongo(**context):
    data = context['ti'].xcom_pull(task_ids='fetch_aircraft_data')
    mongo_conn = BaseHook.get_connection('api_calls_mongodb')
    client = MongoClient(mongo_conn.host, mongo_conn.port, username=mongo_conn.login, password=mongo_conn.password)
    db = client['airline_project']
    collection = db['aircrafts']

    operations = []
    for aircraft in data:
        operations.append(
            UpdateOne(
                {'AircraftCode': aircraft['AircraftCode']},
                {'$set': aircraft},
                upsert=True
            )
        )
    if operations:
        result = collection.bulk_write(operations)
        return result.upserted_count, result.modified_count
    return 0, 0

def insert_to_postgres(**context):
    data = context['ti'].xcom_pull(task_ids='fetch_aircraft_data')
    postgres_conn = BaseHook.get_connection('api_calls_postgres')
    conn = psycopg2.connect(
        dbname=postgres_conn.schema,
        user=postgres_conn.login,
        password=postgres_conn.password,
        host=postgres_conn.host,
        port=postgres_conn.port
    )

    insert_query = """
    CREATE TABLE IF NOT EXISTS aircrafts (
        AircraftCode VARCHAR(255) PRIMARY KEY,
        AirlineEquipCode VARCHAR(255),
        Names TEXT
    );
    INSERT INTO aircrafts (AircraftCode, AirlineEquipCode, Names)
    VALUES (%s, %s, %s)
    ON CONFLICT (AircraftCode) DO UPDATE SET
        AirlineEquipCode = EXCLUDED.AirlineEquipCode,
        Names = EXCLUDED.Names;
    """

    data_to_insert = [
        (
            aircraft['AircraftCode'],
            aircraft.get('AirlineEquipCode', ''),
            ', '.join([name['$'] for name in aircraft['Names']['Name']]) if isinstance(aircraft['Names'].get('Name'), list) else aircraft['Names']['Name']['$'] if 'Names' in aircraft and 'Name' in aircraft['Names'] else ''
        )
        for aircraft in data
    ]
    with conn.cursor() as cursor:
        execute_batch(cursor, insert_query, data_to_insert)
    conn.commit()
    conn.close()
    return len(data)

def export_to_json(**context):
    data = context['ti'].xcom_pull(task_ids='fetch_aircraft_data')
    os.makedirs('/opt/airflow/data/json', exist_ok=True)

    # Déduplication des données
    seen = set()
    unique_aircrafts = []
    for aircraft in data:
        aircraft_code = aircraft['AircraftCode']
        if aircraft_code not in seen:
            seen.add(aircraft_code)
            unique_aircrafts.append(aircraft)
    
    # Sauvegarde des données uniques
    with open('/opt/airflow/data/json/aircrafts.json', 'w') as json_file:
        json.dump(unique_aircrafts, json_file, indent=4)


def export_to_csv_from_json(**context):
    os.makedirs('/opt/airflow/data/csv', exist_ok=True)
    with open('/opt/airflow/data/json/aircrafts.json', 'r') as json_file:
        data = json.load(json_file)
    
    seen = set()
    unique_aircrafts = []
    for item in data:
        aircraft_code = item['AircraftCode']
        if aircraft_code not in seen:
            seen.add(aircraft_code)
            unique_aircrafts.append(item)

    with open('/opt/airflow/data/csv/aircrafts.csv', 'w', newline='') as csv_file:
        fieldnames = ["AircraftCode", "AirlineEquipCode", "Names"]
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writeheader()
        for item in unique_aircrafts:
            writer.writerow({
                "AircraftCode": item['AircraftCode'],
                "AirlineEquipCode": item.get('AirlineEquipCode', ''),
                "Names": ', '.join([name['$'] for name in item['Names']['Name']]) if isinstance(item['Names'].get('Name'), list) else item['Names']['Name']['$'] if 'Names' in item and 'Name' in item['Names'] else ''
            })

def fetch_aircraft_data(**kwargs):
    access_token = get_access_token()
    if not access_token:
        print("Failed to obtain access token.")
        return

    aircraft_data = []
    errors = []

    limit = 100
    offset = 0
    while True:
        data, error = fetch_aircraft_details(access_token, limit, offset)
        if data:
            aircrafts = data['AircraftResource']['AircraftSummaries']['AircraftSummary']
            if not aircrafts:
                break
            aircraft_data.extend(aircrafts)
            offset += limit
            time.sleep(2)
            if len(aircrafts) < limit:
                break
        else:
            errors.append(error)
            send_email_via_smtp("Échec du DAG fetch_aircraft_data", e)
            break

    return aircraft_data

def send_email_via_smtp(subject, body):
    from_email = "mehdi.fekih@edhec.com"
    to_email = "telegram@mailrise.xyz"
    
    msg = MIMEText(body)
    msg["Subject"] = subject
    msg["From"] = from_email
    msg["To"] = to_email
    
    smtp_server = "192.168.10.168"
    smtp_port = 8025
    
    with smtplib.SMTP(smtp_server, smtp_port) as server:
        server.sendmail(from_email, [to_email], msg.as_string())
        logging.info("E-mail envoyé via Mailrise.")
        
fetch_aircraft_data_task = PythonOperator(
    task_id='fetch_aircraft_data',
    python_callable=fetch_aircraft_data,
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
    python_callable=export_to_csv_from_json,
    provide_context=True,
    dag=dag,
)

fetch_aircraft_data_task >> [insert_to_mongo_task, insert_to_postgres_task] >> export_to_json_task >> export_to_csv_task
