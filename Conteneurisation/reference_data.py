import psycopg2
from psycopg2.extras import execute_values
import pandas as pd 

import warnings
warnings.filterwarnings("ignore")


# Fonction pour insérer un DataFrame dans une table PostgreSQL
def insert_dataframe(df, table):
    tuples = [tuple(x) for x in df.to_numpy()]
    cols = ','.join(list(df.columns))
    query = f"INSERT INTO {table}({cols}) VALUES %s ON CONFLICT DO NOTHING"
    cursor = conn.cursor()
    execute_values(cursor, query, tuples)
    conn.commit()

# Connexion à la base de données PostgreSQL
conn = psycopg2.connect(
    dbname="airport_management_db",
    user="postgres",
    password="mysecretpassword",
    host="postgres-container",
    port="5432"
)
cursor = conn.cursor()

countries = pd.read_csv("countries.csv", index_col=0)
cities = pd.read_csv("cities.csv", index_col=0)
aircrafts = pd.read_csv("aircraft.csv", index_col=0)
airports = pd.read_csv("airports.csv", index_col=0)
airlines = pd.read_csv("airlines.csv", index_col=0)

# Remplacer les valeurs manquantes

countries['CountryCode'].fillna('Unknown', inplace=True)  
countries['ZoneCode'].fillna('Unknown', inplace=True)     

cities['CountryCode'].fillna('Unknown', inplace=True)  
cities['Longitude'].fillna(0, inplace=True)
cities['Latitude'].fillna(0, inplace=True) 

airports['CountryCode'].fillna('Unknown', inplace=True)

airlines['AirlineID'].fillna('Unknown', inplace=True) 

cities = cities.drop(["AirportCode"],axis=1)

# Insérer les DataFrames dans les tables PostgreSQL
insert_dataframe(countries, 'Countries')
insert_dataframe(cities, 'Cities')
insert_dataframe(airports, 'Airports')
insert_dataframe(airlines, 'Airlines')
insert_dataframe(aircrafts, 'Aircrafts')

# Fermer la connexion
cursor.close()
conn.close()

