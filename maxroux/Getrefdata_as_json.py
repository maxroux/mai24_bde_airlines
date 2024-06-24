import requests
import json
import os
from tqdm import tqdm

'''
Jun-24 - working as expected - provides all ref data as JSON files in subfolder 'data'.
Windows machine: tested & approved
Virtual machine: to be tested.
'''


def get_all_records(url, offset, limit, output_filename, nested_keys):
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
            data = data.get(key, {})
        return data

    # Initial API call to get the total number of records
    print(f"Fetching data for {output_filename} - connecting...")
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
    with tqdm(total=total_calls, desc=f"Fetching data for {output_filename}", unit="call") as pbar:
        pbar.update(1)  # Update progress for the initial call
        while len(all_records) < total_records:
            offset += limit
            response = requests.get(f"{url}?offset={offset}&limit={limit}", headers=headers)
            data = response.json()

            records = get_nested_data(data, nested_keys)

            if not records:
                break
            all_records.extend(records)
            pbar.update(1)  # Update progress for each API call

            # Check if we have retrieved all records
            if len(all_records) >= total_records or offset>total_records:
                break

    # Create the "data" subfolder if it doesn't exist
    os.makedirs("data", exist_ok=True)

    # Save the output to a JSON file in the "data" subfolder
    with open(os.path.join("data", output_filename), 'w') as f:
        json.dump(all_records, f, indent=4)

    # Print a summary of the action taken
    print(f"\nSuccessfully retrieved {len(all_records)} records and saved them to data/{output_filename}")

    return all_records

# Define the endpoints and keys for different reference data
reference_data_endpoints = {
    "countries": {"url": "https://api.lufthansa.com/v1/references/countries", "nested_keys": ["CountryResource", "Countries","Country"], "filename": "countries.json"},
    "cities": {"url": "https://api.lufthansa.com/v1/references/cities", "nested_keys": ["CityResource", "Cities","City"], "filename": "cities.json"},
    "airports": {"url": "https://api.lufthansa.com/v1/references/airports", "nested_keys": ["AirportResource", "Airports","Airport"], "filename": "airports.json"},
    "airlines": {"url": "https://api.lufthansa.com/v1/references/airlines", "nested_keys": ["AirlineResource", "Airlines","Airline"], "filename": "airlines.json"},
    "aircraft": {"url": "https://api.lufthansa.com/v1/references/aircraft", "nested_keys": ["AircraftResource", "AircraftSummaries", "AircraftSummary"], "filename": "aircraft.json"}
}

# Extract data for each reference type
offset = 0
limit = 100

for ref_type, config in reference_data_endpoints.items():
    print(f"Fetching data for {ref_type}...")
    get_all_records(config["url"], offset, limit, config["filename"], config["nested_keys"])
