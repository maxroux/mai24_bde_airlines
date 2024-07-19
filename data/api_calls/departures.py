import requests
import json
from pymongo import MongoClient
from datetime import datetime
from api_payload import get_access_token
from airport_codes import airport_codes
from datetime import datetime, timedelta

def fetch_departures(access_token, airport_code, date_time):
    url_template = "https://api.lufthansa.com/v1/operations/flightstatus/departures/{airportCode}/{fromDateTime}"
    headers = {
        "Authorization": f"Bearer {access_token}"
    }
    url = url_template.format(airportCode=airport_code, fromDateTime=date_time)
    print(f"Fetching departures for airport code: {airport_code} at {date_time}")
    try:
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            print(f"Success: Retrieved data for {airport_code}")
            return response.json()
        else:
            print(f"Error: Failed to retrieve data for {airport_code} - Status code: {response.status_code} - Reason: {response.reason}")
            return None, {
                "airport_code": airport_code,
                "status_code": response.status_code,
                "reason": response.reason
            }
    except requests.exceptions.RequestException as e:
        print(f"Exception: An error occurred while fetching data for {airport_code} - Error: {str(e)}")
        return None, {
            "airport_code": airport_code,
            "error": str(e)
        }

def insert_to_mongo(collection, airport_code, data):
    print(f"Inserting data for airport code: {airport_code} into MongoDB")
    result = collection.insert_one({
        "airport_code": airport_code,
        "data": data
    })
    print(f"Document inserted with _id: {result.inserted_id}")
    return result.inserted_id

if __name__ == "__main__":
    access_token = get_access_token()

    if not access_token:
        print("Failed to obtain access token.")
        exit(1)

    client = MongoClient('mongodb://mongodb:27017/')
    db = client['airline_project']
    collection = db['airline']

    results = []
    errors = []
    # date_time = datetime.now().strftime("%Y-%m-%dT%H:%M")
    date_time = (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%dT%H:%M")

    for code in airport_codes:
        data, error = fetch_departures(access_token, code, date_time)
        if data:
            inserted_id = insert_to_mongo(collection, code, data)
            print(f"Document inserted with _id: {inserted_id}")
        else:
            errors.append(error)
            print(f"Error: {error}")

    with open("/app/api_errors.json", "w") as json_file:
        json.dump(errors, json_file, indent=4)

    print("Process completed. Check api_errors.json for any errors.")
