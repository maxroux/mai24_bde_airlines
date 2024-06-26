import requests
import psycopg2
import time

# Configuration des paramètres
token_url = "https://api.lufthansa.com/v1/oauth/token"
credentials = {
    'client_id': 'vss6aqb3gf2czn5syafmbrzp3',
    'client_secret': 'VzZCePAxmQ',
    'grant_type': 'client_credentials'
}
header_info = {
    'Content-Type': 'application/x-www-form-urlencoded'
}
database_config = {
    'host': 'localhost',
    'port': '5432',
    'database': 'airline_db',
    'user': 'postgres',
    'password': 'airline'
}

# Obtenir le jeton d'authentification
def get_access_token(url, creds, headers):
    response = requests.post(url, data=creds, headers=headers)
    if response.status_code == 200:
        return response.json().get('access_token')
    else:
        print(f"Erreur: {response.status_code}")
        print(response.json())
        exit()

# Connexion à la base de données
def connect_to_database(config):
    try:
        conn = psycopg2.connect(**config)
        cursor = conn.cursor()
        print("Connexion à la base de données réussie")
        return conn, cursor
    except Exception as error:
        print(f"Erreur de connexion à la base de données: {error}")
        exit()

# Insertion des informations des aéroports dans la base de données
def add_airport_data(cursor, airport_info):
    if airport_info.get('AirportCode'):
        insert_stmt = """
        INSERT INTO airport (airportcode, latitude, longitude, citycode, countrycode, locationtype, airportname)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (airportcode) DO NOTHING;
        """
        try:
            cursor.execute(insert_stmt, (
                airport_info.get('AirportCode'),
                airport_info.get("Position", {}).get("Coordinate", {}).get("Latitude"),
                airport_info.get("Position", {}).get("Coordinate", {}).get("Longitude"),
                airport_info.get('CityCode'),
                airport_info.get('CountryCode'),
                airport_info.get('LocationType'),
                airport_info.get("Names", {}).get("Name", {}).get("$")
            ))
            print(f"Données insérées pour l'aéroport: {airport_info.get('AirportCode')}")
        except Exception as error:
            print(f"Erreur d'insertion pour l'aéroport {airport_info.get('AirportCode')}: {error}")

# Récupération des données des aéroports depuis l'API
def fetch_and_store_airports(api_url, headers, db_cursor, limit=100):
    offset = 0
    total_entries = None

    while True:
        params = {
            "limit": limit,
            "offset": offset,
            "lang": "en"
        }
        response = requests.get(api_url, headers=headers, params=params)
        
        if response.status_code == 500:
            print("Erreur 500: Problème interne du serveur. Nouvelle tentative dans 10 secondes...")
            time.sleep(10)
            continue
        
        if response.status_code != 200:
            print(f"Erreur de récupération des données: {response.status_code}")
            break
        
        data = response.json()
        
        if total_entries is None:
            total_entries = data.get('AirportResource', {}).get('Meta', {}).get('TotalCount', float('inf'))
        
        airports = data.get('AirportResource', {}).get('Airports', {}).get('Airport', [])
        if not airports:
            break
        
        for airport in airports:
            add_airport_data(db_cursor, airport)
        
        try:
            conn.commit()
            print("Batch de données validé")
        except Exception as error:
            print(f"Erreur lors de la validation du batch: {error}")
        
        if len(airports) < limit:
            break
        
        offset += limit

    print(f"Total des aéroports récupérés: {offset}")

# Exécution principale du script
if __name__ == "__main__":
    access_token = get_access_token(token_url, credentials, header_info)
    
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Accept': 'application/json'
    }
    
    conn, cursor = connect_to_database(database_config)
    fetch_and_store_airports("https://api.lufthansa.com/v1/references/airports", headers, cursor)
    
    cursor.close()
    conn.close()
    print("Connexion à la base de données fermée")
