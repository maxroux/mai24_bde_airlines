
import requests
import json
import sys
import io


url ="https://api.lufthansa.com/v1/mds-references/aircraft"
headers = {
    'Authorization': 'Bearer rt4cnr4rcdxvk8sf25uwbgmw',
    'Accept': 'application/json'
}
all_aircraft = []
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
    if response.status_code != 200:
        print(f"Error fetching data: {response.status_code}")
        break
    data = response.json()
    
    # Initialiser total_records si ce n'est pas déjà fait
    if total_records is None:
        total_records = data.get('AircraftResource', {}).get('Meta', {}).get('TotalCount', float('inf'))
    
    aircrafts = data.get('AircraftResource', {}).get('AircraftSummaries', {}).get('AircraftSummary', [])
    if not aircrafts:
        break
    all_aircraft.extend(aircrafts)
    
    # Vérifier si nous avons récupéré tous les enregistrements
    if len(all_aircraft) >= total_records:
        break
    
    offset += limit

print(f"Total airports retrieved: {len(all_aircraft)}")
with open('/Users/Chams/Desktop/airline_project/aircraft.json', 'w', encoding='utf-8') as f:
    json.dump(all_aircraft, f, ensure_ascii=False, indent=4)
print("Les données des aéroports ont été sauvegardées dans all_airports.json")
