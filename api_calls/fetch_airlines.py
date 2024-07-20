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

def fetch_airline_details(access_token, limit, offset):
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
    print(f"Fetching data with limit={limit} and offset={offset}")
    response = requests.get(url, headers=headers, params=params)
    response.raise_for_status()
    return response.json()

def insert_to_mongo(collection, data):
    operations = []
    for airline in data:
        operations.append(
            UpdateOne(
                {'AirlineID': airline['AirlineID']},
                {'$set': airline},
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
        for airline in data
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
        fieldnames = ["AirlineID", "Name"]
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writeheader()
        for item in data:
            writer.writerow({
                "AirlineID": item['AirlineID'],
                "Name": item.get('Name', '')
            })

if __name__ == "__main__":
    access_token = get_access_token()

    client = MongoClient('mongodb://airline:airline@localhost:27017/')
    db = client['airline_project']
    collection = db['airlines']

    conn = psycopg2.connect(
        dbname="airline_project",
        user="airline",
        password="airline",
        host="localhost",
        port="5432"
    )

    airline_data_dict = {}
    errors = []

    initial_limit = 100
    limit = initial_limit
    offset = 0
    calls_per_hour = 0

    json_filename = '../json/airlines.json'
    csv_filename = '../csv/airlines.csv'

    while calls_per_hour < 1000:
        try:
            data = fetch_airline_details(access_token, limit, offset)
            airlines = data['AirlineResource']['Airlines']['Airline']
            if not airlines:
                break
            print(f"Fetched {len(airlines)} airlines")
            insert_to_mongo(collection, airlines)
            insert_to_postgres(conn, airlines)
            for airline in airlines:
                airline_data_dict[airline['AirlineID']] = {
                    'AirlineID': airline['AirlineID'],
                    'Name': airline['Names']['Name']['$'] if isinstance(airline['Names']['Name'], dict) else ''
                }
            offset += limit
            limit = initial_limit  # Reset limit to initial value after successful call
            print("Throttle")
            time.sleep(2)  # Adjusting the sleep time for better throttling

            # Save data after each successful request
            all_airline_data = list(airline_data_dict.values())
            export_to_json(all_airline_data, json_filename)
            export_to_csv_from_json(json_filename, csv_filename)

            # Check if fewer airlines are fetched than the limit, indicating no more data
            if len(airlines) < limit:
                print("Fetched fewer airlines than the limit, stopping the script.")
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

    print("Process completed. Data exported to airlines.json and airlines.csv.")

    conn.close()
