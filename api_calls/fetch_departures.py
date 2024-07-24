import os
import requests
import json
import csv
from pymongo import MongoClient, UpdateOne, errors
from api_payload import get_access_token
from datetime import datetime, timedelta

def fetch_airport_codes(csv_filename):
    with open(csv_filename, 'r') as csv_file:
        reader = csv.reader(csv_file)
        next(reader)  # Sauter l'en-tête si elle existe
        airport_codes = [row[0] for row in reader if row]
    return airport_codes

def fetch_flight_status(airport_code, from_date_time, access_token, offset=0, limit=100):
    url_template = "https://api.lufthansa.com/v1/operations/flightstatus/departures/{airportCode}/{fromDateTime}?offset={offset}&limit={limit}"
    url = url_template.format(airportCode=airport_code, fromDateTime=from_date_time, offset=offset, limit=limit)
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Accept': 'application/json'
    }
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json()

def load_existing_data(json_filename):
    if os.path.exists(json_filename):
        try:
            with open(json_filename, 'r') as json_file:
                return json.load(json_file)
        except json.JSONDecodeError as e:
            print(f"Erreur de décodage JSON dans {json_filename}: {e}")
            return []
    return []

def save_data_to_json(data, json_filename):
    existing_data = load_existing_data(json_filename)
    existing_data.extend(data)
    if os.path.dirname(json_filename):
        os.makedirs(os.path.dirname(json_filename), exist_ok=True)
    with open(json_filename, 'w') as json_file:
        json.dump(existing_data, json_file, indent=4)

def save_data_to_csv(data, csv_filename):
    if os.path.dirname(csv_filename):
        os.makedirs(os.path.dirname(csv_filename), exist_ok=True)
    with open(csv_filename, 'w', newline='') as csv_file:
        fieldnames = ["airport_code", "ScheduledTimeUTC", "FlightNumber", "AirlineID", "DepartureTimeUTC", "ArrivalTimeUTC"]
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writeheader()
        for item in data:
            if 'FlightStatusResource' not in item['data']:
                continue
            flights = item['data']['FlightStatusResource']['Flights']['Flight']
            if not isinstance(flights, list):
                flights = [flights]
            for flight in flights:
                writer.writerow({
                    "airport_code": item["airport_code"],
                    "ScheduledTimeUTC": item["ScheduledTimeUTC"],
                    "FlightNumber": flight['MarketingCarrier']['FlightNumber'],
                    "AirlineID": flight['MarketingCarrier']['AirlineID'],
                    "DepartureTimeUTC": flight['Departure']['ScheduledTimeUTC']['DateTime'] if isinstance(flight['Departure']['ScheduledTimeUTC'], dict) else flight['Departure']['ScheduledTimeUTC'],
                    "ArrivalTimeUTC": flight['Arrival']['ScheduledTimeUTC']['DateTime'] if 'ScheduledTimeUTC' in flight['Arrival'] and isinstance(flight['Arrival']['ScheduledTimeUTC'], dict) else flight['Arrival'].get('ScheduledTimeUTC', "")
                })

def insert_data_to_mongodb(collection, records):
    operations = []
    for record in records:
        if 'FlightStatusResource' not in record['data'] or 'Flights' not in record['data']['FlightStatusResource'] or 'Flight' not in record['data']['FlightStatusResource']['Flights']:
            print(f"Skipping record due to missing FlightStatusResource: {record}")
            continue

        flights = record['data']['FlightStatusResource']['Flights']['Flight']
        if not isinstance(flights, list):
            flights = [flights]

        for flight in flights:
            flight_number = flight['MarketingCarrier']['FlightNumber']
            airline_id = flight['MarketingCarrier']['AirlineID']
            existing_doc = collection.find_one({
                'data.FlightStatusResource.Flights.Flight.MarketingCarrier.AirlineID': airline_id,
                'data.FlightStatusResource.Flights.Flight.MarketingCarrier.FlightNumber': flight_number,
                'ScheduledTimeUTC': record['ScheduledTimeUTC']
            })
            if existing_doc is None:
                operations.append(
                    UpdateOne(
                        {
                            'airport_code': record['airport_code'],
                            'ScheduledTimeUTC': record['ScheduledTimeUTC'],
                            'data.FlightStatusResource.Flights.Flight.MarketingCarrier.FlightNumber': flight_number
                        },
                        {'$set': {k: v for k, v in record.items() if k != '_id'}},
                        upsert=True
                    )
                )
    if operations:
        try:
            result = collection.bulk_write(operations)
            print(f"Mis à jour : {result.upserted_count}, Modifié : {result.modified_count}")
        except errors.BulkWriteError as bwe:
            print(f"Erreur d'écriture bulk : {bwe.details}")

def main():
    print("Démarrage de la fonction principale")
    
    csv_filename = '../data/csv/airport_codes.csv'
    json_filename = '../data/json/departures.json'
    error_json_filename = '../data/json/api_errors.json'
    departures_csv_filename = '../data/csv/departures.csv'
    
    from_date_time = (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%dT00:00')

    print("Récupération des codes d'aéroport depuis le CSV")
    airport_codes = fetch_airport_codes(csv_filename)
    print(f"Trouvé {len(airport_codes)} codes d'aéroport")

    print("Chargement des données existantes depuis les fichiers JSON")
    results = load_existing_data(json_filename)
    errors = load_existing_data(error_json_filename)

    for record in results:
        if 'ScheduledTimeUTC' not in record:
            if 'FlightStatusResource' in record['data'] and \
               'Flights' in record['data']['FlightStatusResource'] and \
               'Flight' in record['data']['FlightStatusResource']['Flights']:
                flights = record['data']['FlightStatusResource']['Flights']['Flight']
                if not isinstance(flights, list):
                    flights = [flights]
                for flight in flights:
                    record['ScheduledTimeUTC'] = flight['Departure']['ScheduledTimeUTC']['DateTime']

    print("Obtention du jeton d'accès")
    access_token = get_access_token()
    print("Jeton d'accès obtenu")

    try:
        client = MongoClient('mongodb://airline:airline@localhost:27017/', serverSelectionTimeoutMS=5000)
        db = client['airline_project']
        collection = db['departures']
    except errors.ServerSelectionTimeoutError as err:
        print(f"Erreur de connexion à MongoDB : {err}")
        return

    print("Insertion des données JSON existantes dans MongoDB")
    insert_data_to_mongodb(collection, results)

    save_data_to_csv(results, departures_csv_filename)

    for code in airport_codes:
        print(f"Récupération du statut de vol pour le code d'aéroport : {code}")
        offset = 0
        while True:
            try:
                data = fetch_flight_status(code, from_date_time, access_token, offset=offset)
                flights = data.get('FlightStatusResource', {}).get('Flights', {}).get('Flight', [])

                if not flights:
                    print(f"Aucun vol trouvé pour le code d'aéroport : {code} à l'offset {offset}")
                    break

                if not isinstance(flights, list):
                    flights = [flights]

                for flight in flights:
                    scheduled_time_utc = flight['Departure']['ScheduledTimeUTC']['DateTime']
                    flight_number = flight['MarketingCarrier']['FlightNumber']
                    airline_id = flight['MarketingCarrier']['AirlineID']
                    
                    # Check for duplicates
                    is_duplicate = any(
                        'FlightStatusResource' in existing_record['data'] and
                        'Flights' in existing_record['data']['FlightStatusResource'] and
                        'Flight' in existing_record['data']['FlightStatusResource']['Flights'] and
                        any(f['MarketingCarrier']['AirlineID'] == airline_id and
                            f['MarketingCarrier']['FlightNumber'] == flight_number and
                            existing_record['ScheduledTimeUTC'] == scheduled_time_utc
                            for f in (existing_record['data']['FlightStatusResource']['Flights']['Flight'] if isinstance(existing_record['data']['FlightStatusResource']['Flights']['Flight'], list) else [existing_record['data']['FlightStatusResource']['Flights']['Flight']]))
                        for existing_record in results
                    )
                    if is_duplicate:
                        continue

                    record = {
                        "airport_code": code,
                        "ScheduledTimeUTC": scheduled_time_utc,
                        "data": {
                            "FlightStatusResource": {
                                "Flights": {
                                    "Flight": {
                                        "Arrival": {
                                            "ActualTimeUTC": flight['Arrival'].get('ActualTimeUTC', ""),
                                            "ScheduledTimeUTC": flight['Arrival']['ScheduledTimeUTC']['DateTime'] if 'ScheduledTimeUTC' in flight['Arrival'] else "",
                                            "AirportCode": flight['Arrival']['AirportCode'] if 'AirportCode' in flight['Arrival'] else "",
                                            "Terminal": flight['Arrival'].get('Terminal', ""),
                                            "TimeStatus": flight['Arrival'].get('TimeStatus', "")
                                        },
                                        "Departure": {
                                            "ActualTimeUTC": flight['Departure'].get('ActualTimeUTC', ""),
                                            "ScheduledTimeUTC": flight['Departure']['ScheduledTimeUTC']['DateTime'] if 'ScheduledTimeUTC' in flight['Departure'] else "",
                                            "AirportCode": flight['Departure']['AirportCode'] if 'AirportCode' in flight['Departure'] else "",
                                            "Terminal": flight['Departure'].get('Terminal', ""),
                                            "TimeStatus": flight['Departure'].get('TimeStatus', "")
                                        },
                                        "Equipment": flight['Equipment'] if 'Equipment' in flight else "",
                                        "FlightStatus": flight['FlightStatus'] if 'FlightStatus' in flight else "",
                                        "MarketingCarrier": flight['MarketingCarrier'] if 'MarketingCarrier' in flight else "",
                                        "OperatingCarrier": flight['OperatingCarrier'] if 'OperatingCarrier' in flight else "",
                                        "ServiceType": flight['ServiceType'] if 'ServiceType' in flight else ""
                                    }
                                },
                                "Meta": data.get('Meta', "")
                            }
                        }
                    }
                    results.append(record)

                    collection.update_one(
                        {
                            'airport_code': code,
                            'ScheduledTimeUTC': scheduled_time_utc,
                            'data.FlightStatusResource.Flights.Flight.MarketingCarrier.FlightNumber': flight_number
                        },
                        {'$set': {k: v for k, v in record.items() if k != '_id'}},
                        upsert=True
                    )
                    print(f"Document mis à jour pour le code d'aéroport : {code} à {scheduled_time_utc}")

                if len(flights) < 100:
                    break

                offset += 100

            except requests.exceptions.RequestException as e:
                errors.append({
                    "airport_code": code,
                    "ScheduledTimeUTC": from_date_time,
                    "error": str(e)
                })
                print(f"Exception de requête pour {code} : {str(e)}")
                break
            except requests.exceptions.HTTPError as http_err:
                errors.append({
                    "airport_code": code,
                    "ScheduledTimeUTC": from_date_time,
                    "status_code": http_err.response.status_code,
                    "reason": http_err.response.reason
                })
                print(f"Erreur HTTP pour {code} : {http_err.response.status_code} - {http_err.response.reason}")
                break

        save_data_to_json(results, json_filename)
        save_data_to_json(errors, error_json_filename)
        save_data_to_csv(results, departures_csv_filename)
        print(f"Données sauvegardées pour le code d'aéroport : {code}")

    print("Processus terminé. Données sauvegardées dans departures.json, departures.csv et api_errors.json")

if __name__ == "__main__":
    main()
