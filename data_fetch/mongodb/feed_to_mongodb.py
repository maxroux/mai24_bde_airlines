import os
import requests
from pymongo import MongoClient

def obtain_token(client_id, client_secret, auth_url):
    payload = {'grant_type': 'client_credentials'}
    response = requests.post(auth_url, data=payload, auth=(client_id, client_secret))
    response.raise_for_status()
    return response.json().get('access_token')

def fetch_data(api_url, headers, start_idx, limit, data_keys):
    full_url = f"{api_url}?offset={start_idx}&limit={limit}"
    response = requests.get(full_url, headers=headers)
    if response.status_code == 403:
        print(f"Access forbidden for URL: {full_url}")
    response.raise_for_status()
    result = response.json()
    return nested_data_extraction(result, data_keys), result

def nested_data_extraction(data, keys):
    for key in keys:
        if isinstance(data, dict):
            data = data.get(key, {})
        else:
            return []
    return data if isinstance(data, list) else []

def adjust_keys(data, replace_char="_"):
    if isinstance(data, dict):
        return {k.replace("$", replace_char): adjust_keys(v, replace_char) for k, v in data.items()}
    elif isinstance(data, list):
        return [adjust_keys(item, replace_char) for item in data]
    else:
        return data

def insert_into_mongo(collection, records, unique_identifier):
    for record in records:
        sanitized_record = adjust_keys(record)
        collection.update_one({unique_identifier: sanitized_record.get(unique_identifier)}, {"$set": sanitized_record}, upsert=True)

def collect_and_store(api_url, headers, collection, data_keys, unique_identifier, start_idx=0, limit=100):
    all_data = []
    data_batch, metadata = fetch_data(api_url, headers, start_idx, limit, data_keys)
    total_records = metadata.get('Meta', {}).get('TotalCount', len(data_batch))
    
    print(f"Total records to fetch: {total_records}")
    total_batches = (total_records + limit - 1) // limit
    
    current_batch = 0
    while start_idx < total_records:
        data_batch, _ = fetch_data(api_url, headers, start_idx, limit, data_keys)
        if not data_batch:
            break
        insert_into_mongo(collection, data_batch, unique_identifier)
        all_data.extend(data_batch)
        start_idx += limit
        current_batch += 1
        print(f"Batch {current_batch}/{total_batches} fetched and stored.")
    
    print(f"Total records fetched and stored: {len(all_data)}")

# Configuration des accès et des routes
CLIENT_ID = 'vss6aqb3gf2czn5syafmbrzp3'
CLIENT_SECRET = 'VzZCePAxmQVzZCePAxmQ'
TOKEN_URL = 'https://api.lufthansa.com/v1/oauth/token'
MONGO_URI = os.getenv('MONGO_URI', 'mongodb://mongo_docker:27017/')
mongo_client = MongoClient(MONGO_URI)
database = mongo_client['airline']

routes = {
    "countries": {"api": "https://api.lufthansa.com/v1/references/countries", "keys": ["CountryResource", "Countries", "Country"], "collection": database.countries, "unique": "CountryCode"},
    "cities": {"api": "https://api.lufthansa.com/v1/references/cities", "keys": ["CityResource", "Cities", "City"], "collection": database.cities, "unique": "CityCode"},
    "airports": {"api": "https://api.lufthansa.com/v1/references/airports", "keys": ["AirportResource", "Airports", "Airport"], "collection": database.airports, "unique": "AirportCode"},
    "airlines": {"api": "https://api.lufthansa.com/v1/references/airlines", "keys": ["AirlineResource", "Airlines", "Airline"], "collection": database.airlines, "unique": "AirlineID"},
    "aircraft": {"api": "https://api.lufthansa.com/v1/references/aircraft", "keys": ["AircraftResource", "AircraftSummaries", "AircraftSummary"], "collection": database.aircraft, "unique": "AircraftCode"}
}

def main():
    access_token = obtain_token(CLIENT_ID, CLIENT_SECRET, TOKEN_URL)
    api_headers = {
        "Accept": "application/json",
        "Authorization": f"Bearer {access_token}"
    }
    
    for entity, config in routes.items():
        print(f"Collecting data for {entity}...")
        collect_and_store(config["api"], api_headers, config["collection"], config["keys"], config["unique"])

if __name__ == "__main__":
    main()
