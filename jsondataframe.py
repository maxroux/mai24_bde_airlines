
import pandas as pd
import json

# Charger le fichier JSON
with open('/Users/Chams/Desktop/airline_project/aircraft.json', 'r') as file:
    data = json.load(file)

aircraft_data = []
for item in data:
   
   aircraft_info = {
      "AircraftCode":item.get("AircraftCode"),
      "AirlineEquipCode":item.get("AirlineEquipCode"),
      "AircraftName":item.get ( "Names",{}).get("Name",{}).get("$"),
         
    }
    
   aircraft_data.append(aircraft_info)

# Créer un DataFrame
df = pd.DataFrame(aircraft_data)

# Afficher les 5 premières lignes
print(df.head(5))

# Sauvegarder dans un fichier CSV
path = '/Users/Chams/Desktop/airline_project/aircraft.csv'
df.to_csv(path, index=False)

