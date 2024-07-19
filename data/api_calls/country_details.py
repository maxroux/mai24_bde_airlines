import requests
import json
import csv
import time
from pymongo import MongoClient, UpdateOne
import psycopg2
from psycopg2.extras import execute_batch
from api_payload import get_access_token

def fetch_country_details(access_token, limit=50, offset=0):
    url = f"https://api.lufthansa.com/v1/mds-references/countries?limit={limit}&offset={offset}&lang={lang}"
    headers = {
        "Authorization": f"Bearer {access_token}"
    }
    print(f"API call # {offset // limit + 1} Offset {offset} limit {limit}")
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.json(), None
    else:
        return None, {
            "status_code": response.status_code,
            "reason": response.reason
        }

def insert_to_mongo(collection, data):
    operations = []
    for country in data:
        operations.append(
            UpdateOne(
                {'CountryCode': country['CountryCode']},
                {'$set': country},
                upsert=True
            )
        )
    if operations:
        result = collection.bulk_write(operations)
        print(f"Upserted: {result.upserted_count}, Modified: {result.modified_count}")
        return result
    return None

def insert_to_postgres(conn, data):
    insert_query = """
    CREATE TABLE IF NOT EXISTS countries (
    CountryCode VARCHAR(10) PRIMARY KEY,
    Names TEXT
    );
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
        for country in data
    ]
    with conn.cursor() as cursor:
        execute_batch(cursor, insert_query, data_to_insert)
    conn.commit()
    print(f"Inserted/Updated {len(data)} records into PostgreSQL")

def export_to_json(data, filename):
    with open(filename, 'w') as json_file:
        json.dump(data, json_file, indent=4, default=str)

def export_to_csv_from_json(json_filename, csv_filename):
    with open(json_filename, 'r') as json_file:
        data = json.load(json_file)
    
    with open(csv_filename, 'w', newline='') as csv_file:
        fieldnames = ["CountryCode", "Names"]
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writeheader()
        for item in data:
            writer.writerow({
                "CountryCode": item['CountryCode'],
                "Names": ', '.join([name['$'] for name in item['Names']['Name']]) if isinstance(item['Names']['Name'], list) else item['Names']['Name']['$']
            })

if __name__ == "__main__":
    access_token = get_access_token()

    if not access_token:
        print("Échec de l'obtention du jeton d'accès.")
        exit(1)

    client = MongoClient('mongodb://localhost:27017/')
    db = client['airline_project']
    collection = db['countries']

    conn = psycopg2.connect(
        dbname="airline_project",
        user="airline",
        password="airline",
        host="localhost",
        port="5432"
    )

    country_data_dict = {}
    errors = []

    limit = 100
    offset = 0
    calls_per_hour = 0
    lang="en"

    while calls_per_hour < 1000:
        data, error = fetch_country_details(access_token, limit, offset)
        if data:
            countries = data['CountryResource']['Countries']['Country']
            if not countries:
                break
            insert_to_mongo(collection, countries)
            insert_to_postgres(conn, countries)
            for country in countries:
                country_data_dict[country['CountryCode']] = country
            offset += limit
        else:
            errors.append(error)
            if error['status_code'] == 404:
                print(f"Arrêt à l'offset {offset} en raison du 404 Not Found")
                break
        
        calls_per_hour += 1
        time.sleep(1)

    all_country_data = list(country_data_dict.values())

    json_filename = 'data/country_data.json'
    csv_filename = 'data/country_data.csv'

    export_to_json(all_country_data, json_filename)
    export_to_csv_from_json(json_filename, csv_filename)

    if errors:
        with open("data/api_errors.json", "w") as json_file:
            json.dump(errors, json_file, indent=4)

    print("Processus terminé. Données exportées vers country_data.json et country_data.csv.")

    conn.close()
