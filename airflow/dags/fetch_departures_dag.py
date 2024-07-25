from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime, timedelta
import os
import requests
import json
import csv
from pymongo import MongoClient, UpdateOne
from pymongo.errors import ServerSelectionTimeoutError, BulkWriteError
from api_payload import get_access_token

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 7, 22),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'fetch_departures_dag',
    default_args=default_args,
    description='DAG pour récupérer les départs des vols quotidiennement',
    schedule_interval=timedelta(days=1),
    catchup=False
)

def fetch_departures():
    # Constants
    csv_filename = '/opt/airflow/data/csv/airport_codes.csv'
    json_filename = '/opt/airflow/data/json/departures.json'
    error_json_filename = '/opt/airflow/data/json/api_errors.json'
    departures_csv_filename = '/opt/airflow/data/csv/departures.csv'
    from_date_time = (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%dT00:00')

    def fetch_airport_codes(csv_filename):
        with open(csv_filename, 'r') as csv_file:
            reader = csv.reader(csv_file)
            next(reader)
            return [row[0] for row in reader if row]

    def fetch_flight_status(airport_code, from_date_time, access_token, offset=0, limit=100):
        url = f"https://api.lufthansa.com/v1/operations/flightstatus/departures/{airport_code}/{from_date_time}?offset={offset}&limit={limit}"
        headers = {
            'Authorization': f'Bearer {access_token}',
            'Accept': 'application/json'
        }
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        return response.json()

    def load_existing_data(json_filename):
        if os.path.exists(json_filename):
            try:
                with open(json_filename, 'r') as json_file:
                    return json.load(json_file)
            except json.JSONDecodeError as e:
                print(f"Erreur de décodage JSON dans {json_filename}: {e}")
                return []
        return []

    def save_data_to_json(data, json_filename):
        try:
            existing_data = load_existing_data(json_filename)
            existing_data.extend(data)
            os.makedirs(os.path.dirname(json_filename), exist_ok=True)
            with open(json_filename, 'w') as json_file:
                json.dump(existing_data, json_file, indent=4)
        except json.JSONDecodeError as e:
            print(f"Erreur de décodage JSON lors de la sauvegarde dans {json_filename}: {e}")


    def save_data_to_csv(data, csv_filename):
        file_exists = os.path.exists(csv_filename)
        os.makedirs(os.path.dirname(csv_filename), exist_ok=True)
        with open(csv_filename, 'a', newline='') as csv_file:  # Mode 'a' pour ajouter
            fieldnames = ["airport_code", "ScheduledTimeUTC", "FlightNumber", "AirlineID", "DepartureTimeUTC", "ArrivalTimeUTC"]
            writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
            if not file_exists:
                writer.writeheader()  # Écrire l'en-tête seulement si le fichier n'existe pas
            for item in data:
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



    def insert_data_to_mongodb(collection, records):
        operations = []
        for record in records:
            if 'FlightStatusResource' not in record['data'] or 'Flights' not in record['data']['FlightStatusResource'] or 'Flight' not in record['data']['FlightStatusResource']['Flights']:
                continue

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

    def connect_to_mongodb():
        try:
            client = MongoClient('mongodb://airline:airline@api_calls_mongodb:27017/', serverSelectionTimeoutMS=5000)
            db = client['airline_project']
            collection = db['departures']
            return collection
        except ServerSelectionTimeoutError as err:
            print(f"Erreur de connexion à MongoDB : {err}")
            return None

    # Main logic
    print("Démarrage de la fonction principale")
    airport_codes = fetch_airport_codes(csv_filename)
    results = load_existing_data(json_filename)
    errors = load_existing_data(error_json_filename)
    access_token = get_access_token()

    collection = connect_to_mongodb()
    if collection is None:
        return

    insert_data_to_mongodb(collection, results)
    save_data_to_csv(results, departures_csv_filename)

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
                    record = {
                        "airport_code": code,
                        "ScheduledTimeUTC": flight['Departure']['ScheduledTimeUTC']['DateTime'],
                        "data": data
                    }
                    results.append(record)
                    collection.update_one(
                        {
                            'airport_code': code,
                            'ScheduledTimeUTC': record['ScheduledTimeUTC'],
                            'data.FlightStatusResource.Flights.Flight.MarketingCarrier.FlightNumber': flight['MarketingCarrier']['FlightNumber']
                        },
                        {'$set': record},
                        upsert=True
                    )

                if len(flights) < 100:
                    break

                offset += 100

            except requests.exceptions.RequestException as e:
                errors.append({
                    "airport_code": code,
                    "ScheduledTimeUTC": from_date_time,
                    "error": str(e)
                })
                break
            except requests.exceptions.HTTPError as http_err:
                errors.append({
                    "airport_code": code,
                    "ScheduledTimeUTC": from_date_time,
                    "status_code": http_err.response.status_code,
                    "reason": http_err.response.reason
                })
                break

        save_data_to_json(results, json_filename)
        save_data_to_json(errors, error_json_filename)
        save_data_to_csv(results, departures_csv_filename)

fetch_departures_task = PythonOperator(
    task_id='fetch_departures_task',
    python_callable=fetch_departures,
    dag=dag,
)

fetch_departures_task
