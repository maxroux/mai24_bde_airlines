import requests
import json
import os
from tqdm import tqdm
from pymongo import MongoClient

'''
Jun-24 - WORK IN PROGRESS - not yet working
'''

def get_all_records(url, offset, limit, collection, nested_keys, unique_key):
    # Your credentials
    CLIENT_ID = 'dg2ap3tn62qr5d85g6xxnbksw'
    CLIENT_SECRET = 'cXPQbNPpWw'
    AUTH_URL = 'https://api.lufthansa.com/v1/oauth/token'


    # Get access token
    auth_response = requests.post(AUTH_URL,
                                  data={'grant_type': 'client_credentials'},
                                  auth=(CLIENT_ID, CLIENT_SECRET))

    access_token = auth_response.json()['access_token']

    headers = {
        "Accept": "application/json",
        "Authorization": f"Bearer {access_token}"
    }

    all_records = []
    total_records = None

    def get_nested_data(data, keys):
        for key in keys:
            if isinstance(data, dict):
                data = data.get(key, {})
            else:
                data = {}
        return data if isinstance(data, list) else []

    # Initial API call to get the total number of records
    print(f"Fetching data for {url} - connecting...")
    response = requests.get(f"{url}?offset={offset}&limit={limit}", headers=headers)
    data = response.json()

    records = get_nested_data(data, nested_keys)
    all_records.extend(records)

    # Initialize total_records if not already done
    if total_records is None:
        total_records = data.get(nested_keys[0], {}).get('Meta', {}).get('TotalCount', float('inf'))
    total_calls = (total_records + limit - 1) // limit  # Calculate total calls, rounding up

    print(f"Total records: {total_records}, Total calls: {total_calls}")

    # Display the progress bar
    with tqdm(total=total_calls, desc=f"Fetching data for {url}", unit="call") as pbar:
        pbar.update(1)  # Update progress for the initial call
        while len(all_records) < total_records:
            offset += limit
            response = requests.get(f"{url}?offset={offset}&limit={limit}", headers=headers)
            data = response.json()

            records = get_nested_data(data, nested_keys)

            if not records:
                break
            for record in records:
                collection.update_one({unique_key: record.get(unique_key)}, {"$set": record}, upsert=True)
            all_records.extend(records)
            pbar.update(1)  # Update progress for each API call

            # Check if we have retrieved all records
            if len(all_records) >= total_records or offset > total_records:
                break

    # Print a summary of the action taken
    print(f"\nSuccessfully retrieved {len(all_records)} records and saved them to MongoDB collection '{collection.name}'")

    return all_records

# MongoDB connection setup
client = MongoClient('mongodb://localhost:27017/')
db = client['lufthansa_db']

# Define the endpoints and keys for different reference data
reference_data_endpoints = {
    "countries": {"url": "https://api.lufthansa.com/v1/references/countries", "nested_keys": ["CountryResource", "Countries", "Country"], "collection": db.countries, "unique_key": "CountryCode"},
    # "cities": {"url": "https://api.lufthansa.com/v1/references/cities", "nested_keys": ["CityResource", "Cities", "City"], "collection": db.cities, "unique_key": "CityCode"},
    # "airports": {"url": "https://api.lufthansa.com/v1/references/airports", "nested_keys": ["AirportResource", "Airports", "Airport"], "collection": db.airports, "unique_key": "AirportCode"},
    # "airlines": {"url": "https://api.lufthansa.com/v1/references/airlines", "nested_keys": ["AirlineResource", "Airlines", "Airline"], "collection": db.airlines, "unique_key": "AirlineID"},
    # "aircraft": {"url": "https://api.lufthansa.com/v1/references/aircraft", "nested_keys": ["AircraftResource", "AircraftSummaries", "AircraftSummary"], "collection": db.aircraft, "unique_key": "AircraftCode"}
}

# Extract data for each reference type
offset = 0
limit = 100

for ref_type, config in reference_data_endpoints.items():
    print(f"Fetching data for {ref_type}...")
    get_all_records(config["url"], offset, limit, config["collection"], config["nested_keys"], config["unique_key"])

# Examples of manipulating the MongoDB database
print("\nMongoDB Data Manipulation Examples:")

# Count documents in a collection
aircraft_count = db.aircraft.count_documents({})
print(f"Total aircraft documents: {aircraft_count}")

# Find one document
one_aircraft = db.aircraft.find_one()
print(f"One aircraft document: {one_aircraft}")

# Find documents with a specific condition
specific_aircraft = db.aircraft.find({"AircraftCode": "320"})
for aircraft in specific_aircraft:
    print(f"Aircraft with code 320: {aircraft}")

'''
# Update a document
db.aircraft.update_one({"AircraftCode": "320"}, {"$set": {"UpdatedField": "NewValue"}})
updated_aircraft = db.aircraft.find_one({"AircraftCode": "320"})
print(f"Updated aircraft document: {updated_aircraft}")

# Delete a document
db.aircraft.delete_one({"AircraftCode": "320"})
deleted_aircraft_count = db.aircraft.count_documents({"AircraftCode": "320"})
print(f"Remaining aircraft with code 320 after deletion: {deleted_aircraft_count}")
'''