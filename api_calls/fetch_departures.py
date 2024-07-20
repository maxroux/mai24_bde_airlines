import os
import requests
import json
import csv
from pymongo import MongoClient, UpdateOne, errors
from api_payload import get_access_token

def fetch_airport_codes(csv_filename):
    with open(csv_filename, 'r') as csv_file:
        reader = csv.reader(csv_file)
        next(reader)  # Sauter l'en-tête si elle existe
        airport_codes = [row[0] for row in reader if row]
    return airport_codes

def fetch_flight_status(airport_code, from_date_time, access_token):
    url_template = "https://api.lufthansa.com/v1/operations/flightstatus/departures/{airportCode}/{fromDateTime}"
    url = url_template.format(airportCode=airport_code, fromDateTime=from_date_time)
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Accept': 'application/json'
    }
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json()

def load_existing_data(json_filename):
    if os.path.exists(json_filename):
        with open(json_filename, 'r') as json_file:
            return json.load(json_file)
    return []

def save_data_to_json(data, json_filename):
    if os.path.dirname(json_filename):
        os.makedirs(os.path.dirname(json_filename), exist_ok=True)
    with open(json_filename, 'w') as json_file:
        json.dump(data, json_file, indent=4)

def save_data_to_csv(data, csv_filename):
    if os.path.dirname(csv_filename):
        os.makedirs(os.path.dirname(csv_filename), exist_ok=True)
    with open(csv_filename, 'w', newline='') as csv_file:
        fieldnames = ["airport_code", "ScheduledTimeUTC", "data"]
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writeheader()
        for item in data:
            writer.writerow({
                "airport_code": item["airport_code"],
                "ScheduledTimeUTC": item["ScheduledTimeUTC"],
                "data": json.dumps(item["data"])  # Convertir les données en chaîne JSON pour le stockage CSV
            })

def main():
    print("Démarrage de la fonction principale")
    
    csv_filename = '../data/csv/airport_codes.csv'
    json_filename = '../data/json/departures.json'
    error_json_filename = 'api_errors.json'
    departures_csv_filename = '../data/csv/departures.csv'
    from_date_time = "2024-07-20T00:00"

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
                flight = record['data']['FlightStatusResource']['Flights']['Flight']
                if isinstance(flight, list):
                    flight = flight[0]
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
    operations = []
    for record in results:
        if 'FlightStatusResource' in record['data'] and \
        'Flights' in record['data']['FlightStatusResource'] and \
        'Flight' in record['data']['FlightStatusResource']['Flights']:
            flight = record['data']['FlightStatusResource']['Flights']['Flight']
            if isinstance(flight, list):
                flight = flight[0]
            flight_number = flight['MarketingCarrier']['FlightNumber']
            operations.append(
                UpdateOne(
                    {
                        'airport_code': record['airport_code'],
                        'ScheduledTimeUTC': record['ScheduledTimeUTC'],
                        'data.MarketingCarrier.FlightNumber': flight_number
                    },
                    {'$set': record},
                    upsert=True
                )
            )
    if operations:
        try:
            result = collection.bulk_write(operations)
            print(f"Mis à jour : {result.upserted_count}, Modifié : {result.modified_count}")
        except errors.BulkWriteError as bwe:
            print(f"Erreur d'écriture bulk : {bwe.details}")

    save_data_to_csv(results, departures_csv_filename)

    for code in airport_codes:
        print(f"Récupération du statut de vol pour le code d'aéroport : {code}")
        try:
            data = fetch_flight_status(code, from_date_time, access_token)
            flights = data.get('FlightStatusResource', {}).get('Flights', {}).get('Flight', [])

            if not flights:
                print(f"Aucun vol trouvé pour le code d'aéroport : {code}")
                break

            if not isinstance(flights, list):
                flights = [flights]

            for flight in flights:
                scheduled_time_utc = flight['Departure']['ScheduledTimeUTC']['DateTime']
                flight_number = flight['MarketingCarrier']['FlightNumber']
                record = {
                    "airport_code": code,
                    "ScheduledTimeUTC": scheduled_time_utc,
                    "data": flight
                }
                results.append(record)

                collection.update_one(
                    {
                        'airport_code': code,
                        'ScheduledTimeUTC': scheduled_time_utc,
                        'data.MarketingCarrier.FlightNumber': flight_number
                    },
                    {'$set': record},
                    upsert=True
                )
                print(f"Document mis à jour pour le code d'aéroport : {code} à {scheduled_time_utc}")

        except requests.exceptions.RequestException as e:
            errors.append({
                "airport_code": code,
                "ScheduledTimeUTC": from_date_time,
                "error": str(e)
            })
            print(f"Exception de requête pour {code} : {str(e)}")
        except requests.exceptions.HTTPError as http_err:
            errors.append({
                "airport_code": code,
                "ScheduledTimeUTC": from_date_time,
                "status_code": http_err.response.status_code,
                "reason": http_err.response.reason
            })
            print(f"Erreur HTTP pour {code} : {http_err.response.status_code} - {http_err.response.reason}")

        save_data_to_json(results, json_filename)
        save_data_to_json(errors, error_json_filename)
        save_data_to_csv(results, departures_csv_filename)
        print(f"Données sauvegardées pour le code d'aéroport : {code}")

    print("Processus terminé. Données sauvegardées dans departures.json, departures.csv et api_errors.json")

if __name__ == "__main__":
    main()
s