import os
import requests
import json
import csv
import time
import random
from pymongo import MongoClient, UpdateOne
import psycopg2
from psycopg2.extras import execute_batch
from api_payload import get_access_token


def fetch_city_details(access_token, limit, offset):
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
    response = requests.get(url, headers=headers, params=params)
    response.raise_for_status()
    return response.json()


def insert_to_mongo(collection, data):
    operations = []
    for city in data:
        operations.append(
            UpdateOne(
                {'CityCode': city['CityCode']},
                {'$set': city},
                upsert=True
            )
        )
    if operations:
        result = collection.bulk_write(operations)
        print(f"Upserted: {result.upserted_count}, Modified: {result.modified_count}")
        return result
    return None


def extract_english_name(city):
    if 'Names' in city and 'Name' in city['Names']:
        names = city['Names']['Name']
        if isinstance(names, list):
            return next((name['$'] for name in names if name['@LanguageCode'] == 'EN'), '')
        elif isinstance(names, dict) and names.get('@LanguageCode') == 'EN':
            return names['$']
    return ''


def format_airports(city):
    if 'Airports' in city and 'AirportCode' in city['Airports']:
        airports = city['Airports']['AirportCode']
        if isinstance(airports, list):
            return ', '.join(airports)
        elif isinstance(airports, str):
            return airports
    return ''


def extract_airport_codes(data):
    airport_codes = set()
    for city in data:
        if 'Airports' in city and 'AirportCode' in city['Airports']:
            codes = city['Airports']['AirportCode']
            if isinstance(codes, list):
                airport_codes.update(codes)
            elif isinstance(codes, str):
                airport_codes.add(codes)
    return sorted(airport_codes)


def insert_to_postgres(conn, data):
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
            for city in data
        ]
        execute_batch(cursor, insert_query, data_to_insert)
    conn.commit()
    print(f"Inserted/Updated {len(data)} records into PostgreSQL")


def export_to_json(data, filename):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with open(filename, 'w') as json_file:
        json.dump(data, json_file, indent=4, default=str)


def export_to_csv_from_json(json_filename, csv_filename):
    os.makedirs(os.path.dirname(csv_filename), exist_ok=True)
    with open(json_filename, 'r') as json_file, open(csv_filename, 'w', newline='') as csv_file:
        data = json.load(json_file)
        fieldnames = ["CityCode", "CountryCode", "Name", "UtcOffset", "TimeZoneId", "Airports"]
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writeheader()
        for item in data:
            writer.writerow({
                "CityCode": item['CityCode'],
                "CountryCode": item.get('CountryCode', ''),
                "Name": item.get('Name', ''),
                "UtcOffset": item.get('UtcOffset', ''),
                "TimeZoneId": item.get('TimeZoneId', ''),
                "Airports": item.get('Airports', '')
            })


def export_airport_codes_to_csv(data, filename):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with open(filename, 'w', newline='') as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(["AirportCode"])
        for code in data:
            writer.writerow([code])


if __name__ == "__main__":
    access_token = get_access_token()

    client = MongoClient('mongodb://airline:airline@localhost:27017/')
    db = client['airline_project']
    collection = db['cities']

    conn = psycopg2.connect(
        dbname="airline_project",
        user="airline",
        password="airline",
        host="localhost",
        port="5432"
    )

    city_data_dict = {}
    all_airport_codes = set()
    errors = []

    initial_limit = 100
    limit = initial_limit
    offset = 0
    calls_per_hour = 0

    json_filename = '../data/json/cities.json'
    csv_filename = '../data/csv/cities.csv'
    airport_json_filename = '../data/json/airport_codes.json'
    airport_csv_filename = '../data/csv/airport_codes.csv'

    while calls_per_hour < 1000:
        try:
            data = fetch_city_details(access_token, limit, offset)
            cities = data['CityResource']['Cities']['City']
            if not cities:
                break
            insert_to_mongo(collection, cities)
            insert_to_postgres(conn, cities)
            all_airport_codes.update(extract_airport_codes(cities))
            for city in cities:
                city_data_dict[city['CityCode']] = city
            offset += limit
            limit = initial_limit
            print("Throttle")
            time.sleep(2)

            # On sauveguarde après chaque api call réussi
            all_city_data = list(city_data_dict.values())
            export_to_json(all_city_data, json_filename)
            export_to_csv_from_json(json_filename, csv_filename)
            export_to_json(list(all_airport_codes), airport_json_filename)
            export_airport_codes_to_csv(all_airport_codes, airport_csv_filename)
            
            # Check if fewer cities are fetched than the limit, indicating no more data
            if len(cities) < limit:
                print("Fetched fewer cities than the limit, stopping the script.")
                break
            
        except requests.exceptions.HTTPError as http_err:
            errors.append({"offset": offset, "status_code": http_err.response.status_code, "reason": str(http_err)})
            if http_err.response.status_code == 404:
                print(f"Stopping at offset {offset} due to 404 Not Found")
                print("Sleeping 10 seconds.")
                time.sleep(10)
                break
            # elif http_err.response.status_code == 500:
            #     limit = random.randint(5, 50)  # Generate new limit value
            #     offset += 1
            #     print(f"Server error at offset {offset}. Retrying with new limit {limit} and offset {offset}...")
            #     time.sleep(10)  # Wait before retrying
            #     continue

        calls_per_hour += 1

    if errors:
        with open("api_errors.json", "w") as json_file:
            json.dump(errors, json_file, indent=4)

    print("Process completed. Data exported to cities.json, cities.csv, airport_codes.json, and airport_codes.csv.")

    conn.close()
