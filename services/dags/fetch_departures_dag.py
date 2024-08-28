from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.hooks.base import BaseHook
from datetime import datetime, timedelta
import os
import requests
import json
import csv
from pymongo import MongoClient, UpdateOne
from pymongo.errors import ServerSelectionTimeoutError, BulkWriteError
from api_payload import get_access_token
import smtplib
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
    'fetch_departures_dag',
    default_args=default_args,
    description='DAG pour récupérer les départs des vols quotidiennement',
    schedule_interval=timedelta(days=1),
    catchup=False,
    tags=['api', 'etl']
)

# Chemins des fichiers
CSV_FILENAME = '/opt/airflow/data/csv/airport_codes.csv'
JSON_FILENAME = '/opt/airflow/data/json/departures.json'
ERROR_JSON_FILENAME = '/opt/airflow/data/json/api_errors.json'
DEPARTURES_CSV_FILENAME = '/opt/airflow/data/csv/departures.csv'

# Fonction pour obtenir les codes d'aéroport
def fetch_airport_codes():
    with open(CSV_FILENAME, 'r') as csv_file:
        reader = csv.reader(csv_file)
        next(reader)
        return [row[0] for row in reader if row]

# Fonction pour récupérer les données de départs de vol
def fetch_flight_status(airport_code, from_date_time, access_token, offset=0, limit=100):
    url = f"https://api.lufthansa.com/v1/operations/flightstatus/departures/{airport_code}/{from_date_time}?offset={offset}&limit={limit}"
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Accept': 'application/json'
    }
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json()

# Fonction pour insérer les données dans MongoDB
def insert_data_to_mongodb(**context):
    records = context['task_instance'].xcom_pull(task_ids='fetch_departures_data')
    mongo_conn = BaseHook.get_connection('api_calls_mongodb')
    client = MongoClient(mongo_conn.host, mongo_conn.port, username=mongo_conn.login, password=mongo_conn.password)
    db = client['airline_project']
    collection = db['departures']

    operations = []
    for record in records:
        flights = record['data']['FlightStatusResource']['Flights']['Flight']
        if not isinstance(flights, list):
            flights = [flights]

        for flight in flights:
            flight_number = flight['MarketingCarrier']['FlightNumber']
            airline_id = flight['MarketingCarrier']['AirlineID']
            if 'ScheduledTimeUTC' not in record:
                print(f"Record without ScheduledTimeUTC: {record}")
                continue

            operations.append(
                UpdateOne(
                    {
                        'airport_code': record['airport_code'],
                        'ScheduledTimeUTC': record['ScheduledTimeUTC'],
                        'data.FlightStatusResource.Flights.Flight.MarketingCarrier.FlightNumber': flight_number
                    },
                    {'$set': {k: v for k, v in record.items() if k != '_id'}},
                    upsert=True
                )
            )

    if operations:
        try:
            print("Connexion à MongoDB réussie, insertion en cours...")
            result = collection.bulk_write(operations)
            print(f"Mis à jour : {result.upserted_count}, Modifié : {result.modified_count}")
        except BulkWriteError as bwe:
            print(f"Erreur d'écriture bulk : {bwe.details}")

# Fonction pour sauvegarder les données en CSV
def save_data_to_csv(**context):
    records = context['task_instance'].xcom_pull(task_ids='fetch_departures_data')
    file_exists = os.path.exists(DEPARTURES_CSV_FILENAME)
    os.makedirs(os.path.dirname(DEPARTURES_CSV_FILENAME), exist_ok=True)
    with open(DEPARTURES_CSV_FILENAME, 'a', newline='') as csv_file:
        fieldnames = ["airport_code", "ScheduledTimeUTC", "FlightNumber", "AirlineID", "DepartureTimeUTC", "ArrivalTimeUTC"]
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        if not file_exists:
            writer.writeheader()
        for item in records:
            if 'ScheduledTimeUTC' not in item:
                continue
            flights = item['data']['FlightStatusResource']['Flights']['Flight']
            if not isinstance(flights, list):
                flights = [flights]
            for flight in flights:
                departure_scheduled_time_utc = flight.get('Departure', {}).get('ScheduledTimeUTC', {})
                arrival_scheduled_time_utc = flight.get('Arrival', {}).get('ScheduledTimeUTC', {})

                writer.writerow({
                    "airport_code": item["airport_code"],
                    "ScheduledTimeUTC": item.get("ScheduledTimeUTC", ""),
                    "FlightNumber": flight['MarketingCarrier']['FlightNumber'],
                    "AirlineID": flight['MarketingCarrier']['AirlineID'],
                    "DepartureTimeUTC": departure_scheduled_time_utc.get('DateTime', "") if isinstance(departure_scheduled_time_utc, dict) else "",
                    "ArrivalTimeUTC": arrival_scheduled_time_utc.get('DateTime', "") if isinstance(arrival_scheduled_time_utc, dict) else ""
                })

# Fonction pour sauvegarder les données en JSON
def save_data_to_json(**context):
    records = context['task_instance'].xcom_pull(task_ids='fetch_departures_data')
    existing_data = load_existing_data(JSON_FILENAME)
    existing_data.extend(records)
    os.makedirs(os.path.dirname(JSON_FILENAME), exist_ok=True)
    with open(JSON_FILENAME, 'w') as json_file:
        json.dump(existing_data, json_file, indent=4)

# Fonction pour charger les données existantes depuis un fichier JSON
def load_existing_data(json_filename):
    if os.path.exists(json_filename):
        try:
            with open(json_filename, 'r') as json_file:
                return json.load(json_file)
        except json.JSONDecodeError as e:
            print(f"Erreur de décodage JSON dans {json_filename}: {e}")
            return []
    return []

# Fonction principale pour récupérer les départs de vols
def fetch_departures_data(**context):
    access_token = get_access_token()
    airport_codes = fetch_airport_codes()
    results = []
    from_date_time = (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%dT00:00')

    for code in airport_codes:
        offset = 0
        while True:
            try:
                data = fetch_flight_status(code, from_date_time, access_token, offset=offset)
                flights = data.get('FlightStatusResource', {}).get('Flights', {}).get('Flight', [])
                if not flights:
                    break
                if not isinstance(flights, list):
                    flights = [flights]
                for flight in flights:
                    results.append({
                        "airport_code": code,
                        "ScheduledTimeUTC": flight['Departure']['ScheduledTimeUTC']['DateTime'],
                        "data": data
                    })
                offset += 100
                if len(flights) < 100:
                    break
            except requests.exceptions.RequestException as e:
                send_email_via_smtp("Échec du DAG fetch_departures", e)
                context['task_instance'].xcom_push(key='api_errors', value=str(e))
                break
            except requests.exceptions.HTTPError as http_err:
                send_email_via_smtp("Échec du DAG fetch_departures", e)
                context['task_instance'].xcom_push(key='api_errors', value=str(http_err))
                break
    return results

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
        
# Définition des tâches Airflow
fetch_departures_data_task = PythonOperator(
    task_id='fetch_departures_data',
    python_callable=fetch_departures_data,
    provide_context=True,
    dag=dag,
)

insert_data_to_mongodb_task = PythonOperator(
    task_id='insert_data_to_mongodb',
    python_callable=insert_data_to_mongodb,
    provide_context=True,
    dag=dag,
)

save_data_to_csv_task = PythonOperator(
    task_id='save_data_to_csv',
    python_callable=save_data_to_csv,
    provide_context=True,
    dag=dag,
)

save_data_to_json_task = PythonOperator(
    task_id='save_data_to_json',
    python_callable=save_data_to_json,
    provide_context=True,
    dag=dag,
)
# une tâche pour déclencher le DAG ML flight_delays_prediction après le succès de ce DAG
trigger_flight_delays_prediction_task = TriggerDagRunOperator(
    task_id='trigger_flight_delays_prediction',
    trigger_dag_id='flight_delays_prediction',
    dag=dag,
    trigger_rule='all_success'
)
trigger_process_airport_flight_data_dag_task = TriggerDagRunOperator(
    task_id='trigger_process_airport_flight_data_dag',
    trigger_dag_id='process_airport_flight_data',
    dag=dag,
    trigger_rule='all_success'
)
# Définition de l'ordre d'exécution des tâches
fetch_departures_data_task >> [insert_data_to_mongodb_task, save_data_to_csv_task, save_data_to_json_task] >> trigger_flight_delays_prediction_task >> trigger_process_airport_flight_data_dag_task
