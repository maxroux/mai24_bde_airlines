import requests
import json
import csv
import time
from pymongo import MongoClient, UpdateOne
import psycopg2
from psycopg2.extras import execute_batch
from api_payload import get_access_token

def fetch_airport_details(access_token, limit=100, offset=0):
    url = f"https://api.lufthansa.com/v1/mds-references/airports?limit={limit}&offset={offset}&languageCode=EN"
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
    for airport in data:
        operations.append(
            UpdateOne(
                {'AirportCode': airport['AirportCode']},
                {'$set': airport},
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
    DROP TABLE IF EXISTS airports;
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
        for airport in data
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
        fieldnames = ["AirportCode", "CityCode", "CountryCode", "LocationType", "Latitude", "Longitude", "TimeZoneId", "UtcOffset", "Names"]
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writeheader()
        for item in data:
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

if __name__ == "__main__":
    access_token = get_access_token()

    if not access_token:
        print("Failed to obtain access token.")
        exit(1)

    client = MongoClient('mongodb://localhost:27017/')
    db = client['airline_project']
    collection = db['airports']

    conn = psycopg2.connect(
        dbname="airline_project",
        user="airline",
        password="airline",
        host="localhost",
        port="5432"
    )

    airport_data_dict = {}
    errors = []

    limit = 20
    offset = 0
    calls_per_hour = 0

    while calls_per_hour < 1000:
        data, error = fetch_airport_details(access_token, limit, offset)
        if data:
            airports = data['AirportResource']['Airports']['Airport']
            if not airports:
                break
            insert_to_mongo(collection, airports)
            insert_to_postgres(conn, airports)
            for airport in airports:
                airport_data_dict[airport['AirportCode']] = airport
            offset += limit
            print("Throttle")
            time.sleep(2)  # Adjusting the sleep time for better throttling
        else:
            errors.append(error)
            if error['status_code'] == 404:
                print(f"Stopping at offset {offset} due to 404 Not Found")
                print("sleeping 10 seconds.")
                time.sleep(10)
                break
        
        calls_per_hour += 1

    all_airport_data = list(airport_data_dict.values())

    json_filename = 'data/airport_data.json'
    csv_filename = 'data/airport_data.csv'

    export_to_json(all_airport_data, json_filename)
    export_to_csv_from_json(json_filename, csv_filename)

    if errors:
        with open("api_errors.json", "w") as json_file:
            json.dump(errors, json_file, indent=4)

    print("Process completed. Data exported to airport_data.json and airport_data.csv.")

    conn.close()