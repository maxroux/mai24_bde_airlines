import os
import requests
import json
import csv
import time
from pymongo import MongoClient, UpdateOne
import psycopg2
from psycopg2.extras import execute_batch
from api_payload import get_access_token

def fetch_aircraft_details(access_token, limit=100, offset=0):
    url = f"https://api.lufthansa.com/v1/mds-references/aircraft?limit={limit}&offset={offset}&languageCode=EN"
    
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
        print(f"Upserted: {result.upserted_count}, Modified: {result.modified_count}")
        return result
    return None

def insert_to_postgres(conn, data):
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
        fieldnames = ["AircraftCode", "AirlineEquipCode", "Names"]
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writeheader()
        for item in data:
            writer.writerow({
                "AircraftCode": item['AircraftCode'],
                "AirlineEquipCode": item.get('AirlineEquipCode', ''),
                "Names": ', '.join([name['$'] for name in item['Names']['Name']]) if isinstance(item['Names'].get('Name'), list) else item['Names']['Name']['$'] if 'Names' in item and 'Name' in item['Names'] else ''
            })

if __name__ == "__main__":
    access_token = get_access_token()

    if not access_token:
        print("Failed to obtain access token.")
        exit(1)

    client = MongoClient('mongodb://airline:airline@localhost:27017/')
    db = client['airline_project']
    collection = db['aircrafts']

    conn = psycopg2.connect(
        dbname="airline_project",
        user="airline",
        password="airline",
        host="localhost",
        port="5432"
    )

    aircraft_data_dict = {}
    errors = []

    limit = 100
    offset = 0
    calls_per_hour = 0

    while calls_per_hour < 1000:
        data, error = fetch_aircraft_details(access_token, limit, offset)
        if data:
            aircrafts = data['AircraftResource']['AircraftSummaries']['AircraftSummary']
            if not aircrafts:
                print("No more aircraft data available.")
                break
            insert_to_mongo(collection, aircrafts)
            insert_to_postgres(conn, aircrafts)
            for aircraft in aircrafts:
                aircraft_data_dict[aircraft['AircraftCode']] = aircraft
            offset += limit
            print("Throttle")
            time.sleep(2)  # Adjusting the sleep time for better throttling
            
            # Check if fewer aircrafts are fetched than the limit, indicating no more data
            if len(aircrafts) < limit:
                print("Fetched fewer aircrafts than the limit, stopping the script.")
                break
        else:
            errors.append(error)
            if error['status_code'] == 404:
                print(f"Stopping at offset {offset} due to 404 Not Found")
                print("sleeping 10 seconds.")
                time.sleep(10)
                break
        
        calls_per_hour += 1

    all_aircraft_data = list(aircraft_data_dict.values())

    json_filename = '../json/aircrafts.json'
    csv_filename = '../csv/aircrafts.csv'

    export_to_json(all_aircraft_data, json_filename)
    export_to_csv_from_json(json_filename, csv_filename)

    if errors:
        with open("api_errors.json", "w") as json_file:
            json.dump(errors, json_file, indent=4)

    print("Process completed. Data exported to aircrafts.json and aircrafts.csv.")

    conn.close()
