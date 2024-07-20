import os
import sys
import json
import csv
import requests
from datetime import datetime, timedelta
from pymongo import MongoClient, UpdateOne
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.operators.dummy_operator import DummyOperator

# Ajouter le chemin pour l'importation de get_access_token
sys.path.append('/opt/airflow/data/api_calls')
from api_payload import get_access_token

# Paramètres de Telegram
TELEGRAM_TOKEN = '6825963580:AAHjofVzBFtyZtqOVbd0Fk0zvG2EjgQFcyM'
TELEGRAM_CHAT_ID = '327601094'

def fetch_airport_codes(csv_filename):
    print(f"Vérification de l'existence du fichier: {csv_filename}")
    if not os.path.exists(csv_filename):
        raise FileNotFoundError(f"Le fichier {csv_filename} n'existe pas.")
    
    with open(csv_filename, 'r') as csv_file:
        reader = csv.reader(csv_file)
        next(reader)  # Sauter l'en-tête si elle existe
        airport_codes = [row[0] for row in reader if row]
    return airport_codes

def fetch_flight_status(airport_code, from_date_time, access_token):
    url_template = "https://api.lufthansa.com/v1/operations/flightstatus/departures/{airportCode}/{fromDateTime}"
    url = url_template.format(airportCode=airport_code, fromDateTime=from_date_time)
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Accept': 'application/json'
    }
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json()

def load_existing_data(json_filename):
    print(f"Vérification de l'existence du fichier: {json_filename}")
    if os.path.exists(json_filename):
        with open(json_filename, 'r') as json_file:
            return json.load(json_file)
    return []

def save_data_to_json(data, json_filename):
    if os.path.dirname(json_filename):
        os.makedirs(os.path.dirname(json_filename), exist_ok=True)
    with open(json_filename, 'w') as json_file:
        json.dump(data, json_file, indent=4)

def save_data_to_csv(data, csv_filename):
    if os.path.dirname(csv_filename):
        os.makedirs(os.path.dirname(csv_filename), exist_ok=True)
    with open(csv_filename, 'w', newline='') as csv_file:
        fieldnames = ["airport_code", "ScheduledTimeUTC", "data"]
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writeheader()
        for item in data:
            writer.writerow({
                "airport_code": item["airport_code"],
                "ScheduledTimeUTC": item["ScheduledTimeUTC"],
                "data": json.dumps(item["data"])  # Convertir les données en chaîne JSON pour le stockage CSV
            })

def fetch_departures():
    csv_filename = '/opt/airflow/data/csv/airport_codes.csv'
    json_filename = '/opt/airflow/data/json/departures.json'
    error_json_filename = '/opt/airflow/data/json/api_errors.json'
    departures_csv_filename = '/opt/airflow/data/csv/departures.csv'
    from_date_time = "2024-07-20T00:00"

    airport_codes = fetch_airport_codes(csv_filename)
    results = load_existing_data(json_filename)
    errors = load_existing_data(error_json_filename)

    for record in results:
        if 'ScheduledTimeUTC' not in record:
            record['ScheduledTimeUTC'] = record['data']['FlightStatusResource']['Flights']['Flight'][0]['Departure']['ScheduledTimeUTC']['DateTime']

    access_token = get_access_token()

    client = MongoClient('mongodb://localhost:27017/')
    db = client['airline_project']
    collection = db['departures']

    existing_records = {(record['airport_code'], record['ScheduledTimeUTC']) for record in results}

    operations = []
    for record in results:
        record_copy = record.copy()
        if '_id' in record_copy:
            del record_copy['_id']
        operations.append(
            UpdateOne(
                {'airport_code': record['airport_code'], 'ScheduledTimeUTC': record['ScheduledTimeUTC']},
                {'$set': record_copy},
                upsert=True
            )
        )
    if operations:
        collection.bulk_write(operations)

    save_data_to_csv(results, departures_csv_filename)

    for code in airport_codes:
        try:
            data = fetch_flight_status(code, from_date_time, access_token)
            for flight in data['FlightStatusResource']['Flights']['Flight']:
                scheduled_time_utc = flight['Departure']['ScheduledTimeUTC']['DateTime']
                record = {
                    "airport_code": code,
                    "ScheduledTimeUTC": scheduled_time_utc,
                    "data": flight
                }
                if not any(r['airport_code'] == code and r['ScheduledTimeUTC'] == scheduled_time_utc for r in results):
                    results.append(record)
                collection.update_one(
                    {'airport_code': code, 'ScheduledTimeUTC': scheduled_time_utc},
                    {'$set': record},
                    upsert=True
                )
        except requests.exceptions.RequestException as e:
            errors.append({
                "airport_code": code,
                "ScheduledTimeUTC": from_date_time,
                "error": str(e)
            })
        except requests.exceptions.HTTPError as http_err:
            errors.append({
                "airport_code": code,
                "ScheduledTimeUTC": from_date_time,
                "status_code": http_err.response.status_code,
                "reason": http_err.response.reason
            })

        save_data_to_json(results, json_filename)
        save_data_to_json(errors, error_json_filename)
        save_data_to_csv(results, departures_csv_filename)



default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'fetch_departures_dag',
    default_args=default_args,
    description='DAG pour récupérer et mettre à jour les données des départs chaque jour',
    schedule_interval=timedelta(days=1),
    start_date=datetime(2024, 1, 1),
    catchup=False,
)

start = DummyOperator(task_id='start', dag=dag)

fetch_task = PythonOperator(
    task_id='fetch_departures',
    python_callable=fetch_departures,
    dag=dag,
)


end = DummyOperator(task_id='end', dag=dag)

start >> fetch_task >> end
#notify_task >> end
