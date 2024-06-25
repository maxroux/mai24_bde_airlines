
import requests
import json
import psycopg2
import time 

url = "https://api.lufthansa.com/v1/references/airports"
headers = {
    'Authorization': 'Bearer rsusrcmgnveq6t3wq2f9zbyh',
    'Accept': 'application/json'
}
#authentification pour postgrsql
db_params = {
    'host': 'localhost',
    'port': '5432',
    'database': 'airline_project',
    'user': 'postgres',
    'password': 'sirine'
}
#se connecter au postgrsql
try:
    conn = psycopg2.connect(**db_params)
    cur = conn.cursor()
    print("Connected to the database")
except Exception as e:
    print(f"Error connecting to the database: {e}")
    exit()

#la fonction qui permet d'insérer les données dans la table sur postgrsql
def insert_airports(airport):
    
    if airport.get('AirportCode') is not None:
        insert_query = """
        INSERT INTO airport (airportcode, latitude, longitude, citycode, countrycode, locationtype, airportname)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (airportcode) DO NOTHING;
        """
        try:
            cur.execute(insert_query, (
                airport.get('AirportCode'),
                airport.get("Position", {}).get("Coordinate", {}).get("Latitude"),
                airport.get("Position", {}).get("Coordinate", {}).get("Longitude"),
                airport.get('CityCode'),
                airport.get('CountryCode'),
                airport.get('LocationType'),
                airport.get("Names", {}).get("Name", {}).get("$")
            ))
            print(f"Inserted airport: {airport.get('AirportCode')}")
        except Exception as e:
            print(f"Error inserting airport {airport.get('AirportCode')}: {e}")
#axtraction des données depuis l'api et stockage des données dans postgrsql
limit = 100
offset = 0
total_records = None

while True:
    params = {
        "limit": limit,
        "offset": offset,
        "lang": "en"
    }
    response = requests.get(url, headers=headers, params=params)
    
    if response.status_code == 500:
        print("Error 500: Internal Server Error. Retrying after 10 seconds...")
        time.sleep(10)  
        continue
    
    if response.status_code != 200:
        print(f"Error fetching data: {response.status_code}")
        break
    
    data = response.json()
    
   
    if total_records is None:
        total_records = data.get('AirportResource', {}).get('Meta', {}).get('TotalCount', float('inf'))
    
    airports = data.get('AirportResource', {}).get('Airports', {}).get('Airport', [])
    if not airports:
        break
    
    for airport in airports:
        insert_airports(airport)
    
    try:
        conn.commit()
        print("Batch committed")
    except Exception as e:
        print(f"Error committing batch: {e}")
    
    
    if len(airports) < limit:
        break
    
    offset += limit

print(f"Total airports retrieved: {offset}")

cur.close()
conn.close()
print("Database connection closed")