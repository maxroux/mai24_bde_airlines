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
    'fetch_cities_data_dag',
    default_args=default_args,
    description='DAG pour récupérer les détails des villes et les stocker dans MongoDB et PostgreSQL',
    schedule_interval=timedelta(days=30),
    catchup=False,
    tags=['api', 'etl']
)

# Fonction pour récupérer les détails des villes depuis l'API Lufthansa
def fetch_city_details(**kwargs):
    access_token = get_access_token()
    limit = kwargs.get('limit', 100)
    offset = kwargs.get('offset', 0)
    
    url = "https://api.lufthansa.com/v1/references/cities"
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Accept': 'application/json'
    }
    params = {
        "limit": limit,
        "offset": offset,
        "lang": "en"
    }

    all_cities = []
    while True:
        response = requests.get(url, headers=headers, params=params)
        response.raise_for_status()
        data = response.json()
        cities = data['CityResource']['Cities']['City']
        all_cities.extend(cities)
        
        # Vérifie si on a atteint le nombre total d'enregistrements ou s'il n'y a plus de données
        if len(cities) < limit:
            break
        offset += limit
        params['offset'] = offset
    
    return {"CityResource": {"Cities": {"City": all_cities}}}

# Fonction pour insérer les données dans MongoDB
def insert_to_mongo(**context):
    data = context['ti'].xcom_pull(task_ids='fetch_city_data')
    mongo_conn = BaseHook.get_connection('api_calls_mongodb')
    client = MongoClient(mongo_conn.host, mongo_conn.port, username=mongo_conn.login, password=mongo_conn.password)
    db = client['airline_project']
    collection = db['cities']

    operations = []
    for city in data['CityResource']['Cities']['City']:
        operations.append(
            UpdateOne(
                {'CityCode': city['CityCode']},
                {'$set': city},
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
    data = context['ti'].xcom_pull(task_ids='fetch_city_data')
    postgres_conn = BaseHook.get_connection('api_calls_postgres')
    conn = psycopg2.connect(
        dbname=postgres_conn.schema,
        user=postgres_conn.login,
        password=postgres_conn.password,
        host=postgres_conn.host,
        port=postgres_conn.port
    )

    create_table_query = """
    CREATE TABLE IF NOT EXISTS cities (
        CityCode VARCHAR(10) PRIMARY KEY,
        CountryCode VARCHAR(10),
        Name TEXT,
        UtcOffset VARCHAR(10),
        TimeZoneId VARCHAR(50),
        Airports TEXT
    );
    """
    insert_query = """
    INSERT INTO cities (CityCode, CountryCode, Name, UtcOffset, TimeZoneId, Airports)
    VALUES (%s, %s, %s, %s, %s, %s)
    ON CONFLICT (CityCode) DO UPDATE SET
        CountryCode = EXCLUDED.CountryCode,
        Name = EXCLUDED.Name,
        UtcOffset = EXCLUDED.UtcOffset,
        TimeZoneId = EXCLUDED.TimeZoneId,
        Airports = EXCLUDED.Airports;
    """
    with conn.cursor() as cursor:
        cursor.execute(create_table_query)
        data_to_insert = [
            (
                city['CityCode'],
                city.get('CountryCode', ''),
                extract_english_name(city),
                city.get('UtcOffset', ''),
                city.get('TimeZoneId', ''),
                format_airports(city)
            )
            for city in data['CityResource']['Cities']['City']
        ]
        execute_batch(cursor, insert_query, data_to_insert)
    conn.commit()
    conn.close()
    return len(data)

# Fonction pour mettre à jour les champs vides dans "cities" avec les données de "airports"
def update_city_data_with_airport_data(city, airport):
    fields_to_update = ['Name', 'UtcOffset', 'TimeZoneId', 'Airports']
    for field in fields_to_update:
        if not city.get(field) and airport.get(field):
            city[field] = airport[field]
    return city

# Fonction mise à jour pour extraire le nom en anglais, ou n'importe quel nom disponible
def extract_english_name(city):
    if 'Names' in city and 'Name' in city['Names']:
        names = city['Names']['Name']
        if isinstance(names, list):
            return next((name['$'] for name in names if name.get('@LanguageCode') == 'EN'), names[0]['$'] if names else '')
        elif isinstance(names, dict):
            return names.get('$', '')
    return ''

# Fonction pour synchroniser les données des villes avec celles des aéroports
def synchronize_city_with_airport_data(city_data, airport_data):
    airport_lookup = {airport['AirportCode']: airport for airport in airport_data['AirportResource']['Airports']['Airport']}
    for city in city_data['CityResource']['Cities']['City']:
        if 'Airports' in city and 'AirportCode' in city['Airports']:
            airport_code = city['Airports']['AirportCode']
            if isinstance(airport_code, list):
                airport_code = airport_code[0]
            airport = airport_lookup.get(airport_code)
            if airport:
                city = update_city_data_with_airport_data(city, airport)
    return city_data

# Mise à jour des tâches existantes pour inclure la synchronisation des données
def fetch_and_update_city_data(**kwargs):
    city_data = fetch_city_details(**kwargs)
    airport_data = fetch_all_airport_details(**kwargs)
    updated_city_data = synchronize_city_with_airport_data(city_data, airport_data)
    return updated_city_data

# Fonction pour formater les aéroports en une chaîne
def format_airports(city):
    if 'Airports' in city and 'AirportCode' in city['Airports']:
        airports = city['Airports']['AirportCode']
        if isinstance(airports, list):
            return ', '.join(airports)
        elif isinstance(airports, str):
            return airports
    return ''

# Fonction pour extraire les codes des aéroports
def extract_airport_codes(data):
    airport_codes = set()
    for city in data['CityResource']['Cities']['City']:
        if 'Airports' in city and 'AirportCode' in city['Airports']:
            codes = city['Airports']['AirportCode']
            if isinstance(codes, list):
                airport_codes.update(codes)
            elif isinstance(codes, str):
                airport_codes.add(codes)
    return sorted(airport_codes)

# Fonction pour exporter les données en JSON
def export_to_json(**context):
    data = context['ti'].xcom_pull(task_ids='fetch_city_data')
    unique_cities = []
    seen = set()
    for city in data['CityResource']['Cities']['City']:
        if city['CityCode'] not in seen:
            seen.add(city['CityCode'])
            unique_cities.append(city)
    
    json_filename = '/opt/airflow/data/json/cities.json'
    os.makedirs(os.path.dirname(json_filename), exist_ok=True)
    with open(json_filename, 'w') as json_file:
        json.dump({"CityResource": {"Cities": {"City": unique_cities}}}, json_file, indent=4)


# Fonction pour exporter les données de JSON vers CSV
def export_to_csv(**context):
    json_filename = '/opt/airflow/data/json/cities.json'
    csv_filename = '/opt/airflow/data/csv/cities.csv'
    os.makedirs(os.path.dirname(csv_filename), exist_ok=True)
    with open(json_filename, 'r') as json_file:
        data = json.load(json_file)
    
    unique_cities = []
    seen = set()
    for item in data['CityResource']['Cities']['City']:
        if item['CityCode'] not in seen:
            seen.add(item['CityCode'])
            unique_cities.append(item)

    with open(csv_filename, 'w', newline='') as csv_file:
        fieldnames = ["CityCode", "CountryCode", "Name", "UtcOffset", "TimeZoneId", "Airports"]
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writeheader()
        for item in unique_cities:
            writer.writerow({
                "CityCode": item['CityCode'],
                "CountryCode": item.get('CountryCode', ''),
                "Name": item.get('Name', ''),
                "UtcOffset": item.get('UtcOffset', ''),
                "TimeZoneId": item.get('TimeZoneId', ''),
                "Airports": item.get('Airports', '')
            })

# Fonction pour exporter les codes des aéroports en CSV
def export_airport_codes_to_csv(**context):
    data = context['ti'].xcom_pull(task_ids='fetch_city_data')
    airport_codes = extract_airport_codes(data)
    airport_csv_filename = '/opt/airflow/data/csv/airport_codes.csv'
    os.makedirs(os.path.dirname(airport_csv_filename), exist_ok=True)
    with open(airport_csv_filename, 'w', newline='') as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(["AirportCode"])
        for code in airport_codes:
            writer.writerow([code])

# Définition des tâches Airflow
fetch_city_data_task = PythonOperator(
    task_id='fetch_city_data',
    python_callable=fetch_and_update_city_data,
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

export_airport_codes_task = PythonOperator(
    task_id='export_airport_codes_to_csv',
    python_callable=export_airport_codes_to_csv,
    provide_context=True,
    dag=dag,
)

# Définition de l'ordre d'exécution des tâches
fetch_city_data_task >> [insert_to_mongo_task, insert_to_postgres_task] >> export_to_json_task >> export_to_csv_task >> export_airport_codes_task
