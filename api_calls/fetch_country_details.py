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

def fetch_country_details(access_token, limit, offset):
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
    print(f"Fetching data with limit={limit} and offset={offset}")
    response = requests.get(url, headers=headers, params=params)
    response.raise_for_status()
    return response.json()

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
        for country in data
    ]
    with conn.cursor() as cursor:
        cursor.execute(create_table_query)
        execute_batch(cursor, insert_query, data_to_insert)
    conn.commit()
    print(f"Inserted/Updated {len(data)} records into PostgreSQL")

def export_to_json(data, filename):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with open(filename, 'w') as json_file:
        json.dump(data, json_file, indent=4, default=str)

def export_to_csv_from_json(json_filename, csv_filename):
    os.makedirs(os.path.dirname(csv_filename), exist_ok=True)
    with open(json_filename, 'r') as json_file:
        data = json.load(json_file)
    
    with open(csv_filename, 'w', newline='') as csv_file:
        fieldnames = ["CountryCode", "Names"]
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writeheader()
        for item in data:
            writer.writerow({
                "CountryCode": item['CountryCode'],
                "Names": item.get('Names', '')
            })

if __name__ == "__main__":
    access_token = get_access_token()

    if not access_token:
        print("Failed to obtain access token.")
        exit(1)

    client = MongoClient('mongodb://airline:airline@localhost:27017/')
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

    initial_limit = 100
    limit = initial_limit
    offset = 0
    calls_per_hour = 0

    json_filename = '../json/countries.json'
    csv_filename = '../csv/countries.csv'

    while calls_per_hour < 1000:
        try:
            data = fetch_country_details(access_token, limit, offset)
            countries = data['CountryResource']['Countries']['Country']
            if not countries:
                break
            print(f"Fetched {len(countries)} countries")
            insert_to_mongo(collection, countries)
            insert_to_postgres(conn, countries)
            for country in countries:
                country_data_dict[country['CountryCode']] = {
                    'CountryCode': country['CountryCode'],
                    'Names': ', '.join([name['$'] for name in country['Names']['Name']]) if isinstance(country['Names']['Name'], list) else country['Names']['Name']['$']
                }
            offset += limit
            limit = initial_limit  # Reset limit to initial value after successful call
            print("Throttle")
            time.sleep(2)  # Adjusting the sleep time for better throttling

            # Save data after each successful request
            all_country_data = list(country_data_dict.values())
            export_to_json(all_country_data, json_filename)
            export_to_csv_from_json(json_filename, csv_filename)

            # Check if fewer countries are fetched than the limit, indicating no more data
            if len(countries) < limit:
                print("Fetched fewer countries than the limit, stopping the script.")
                break

        except requests.exceptions.HTTPError as http_err:
            errors.append({"offset": offset, "status_code": http_err.response.status_code, "reason": str(http_err)})
            if http_err.response.status_code == 404:
                print(f"Stopping at offset {offset} due to 404 Not Found")
                print("Sleeping 10 seconds.")
                time.sleep(10)
                break
            elif http_err.response.status_code == 500:
                limit = random.randint(5, 50)  # Generate new limit value
                offset += 1
                print(f"Server error at offset {offset}. Retrying with new limit {limit} and offset {offset}...")
                time.sleep(10)  # Wait before retrying
                continue
        
        calls_per_hour += 1

    if errors:
        with open("api_errors.json", "w") as json_file:
            json.dump(errors, json_file, indent=4)

    print("Process completed. Data exported to countries.json and countries.csv.")

    conn.close()
