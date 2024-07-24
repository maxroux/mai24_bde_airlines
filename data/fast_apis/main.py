from fastapi import FastAPI, HTTPException
from motor.motor_asyncio import AsyncIOMotorClient
from bson import ObjectId
import os
import logging
import pickle
import pandas as pd
from pydantic import BaseModel
from typing import List, Dict

# Environment variables setup
MONGO_URI = os.getenv('MONGO_URI', 'mongodb://airline:airline@mongodb:27017/')
DATABASE_NAME = os.getenv('DATABASE_NAME', 'airline_project')

# MongoDB connection setup
client = AsyncIOMotorClient(MONGO_URI)
db = client[DATABASE_NAME]

# FastAPI app initialization
app = FastAPI()

# Configure logging
logging.basicConfig(level=logging.INFO)

# On charge le modèle picklé
with open('best_model.pkl', 'rb') as model_file:
    model = pickle.load(model_file)

# Définir un modèle Pydantic pour la prédiction
class PredictionRequest(BaseModel):
    airport_code: str
    DepartureScheduledTimeUTC: str
    ArrivalAirportCode: str

def convert_object_ids(records):
    """Convert ObjectId to string in multiple records."""
    return [{**record, "_id": str(record["_id"])} if "_id" in record and isinstance(record["_id"], ObjectId) else record for record in records]

async def fetch_records(collection_name, query, limit, offset):
    """Fetch records from the MongoDB collection based on the query."""
    collection = db[collection_name]
    logging.info(f"MongoDB query on {collection_name}: {query}")
    try:
        records = await collection.find(query).skip(offset).limit(limit).to_list(length=limit)
        logging.info(f"Fetched {len(records)} records from {collection_name}")
        if not records:
            logging.info("No records found")
            raise HTTPException(status_code=404, detail="No records found")
        return convert_object_ids(records)
    except Exception as e:
        logging.error(f"Error fetching records from {collection_name}: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error")

async def fetch_record(collection_name, query):
    """Fetch a single record from the MongoDB collection based on the query."""
    collection = db[collection_name]
    logging.info(f"MongoDB query on {collection_name}: {query}")
    try:
        record = await collection.find_one(query)
        if not record:
            logging.info("No record found")
            raise HTTPException(status_code=404, detail="No record found")
        return convert_object_ids([record])[0]
    except Exception as e:
        logging.error(f"Error fetching record from {collection_name}: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error")

@app.get("/")
async def get_all_routes():
    routes = [
        {"method": "GET", "endpoint": "/countries"},
        {"method": "GET", "endpoint": "/countries/{country_code}"},
        {"method": "GET", "endpoint": "/aircrafts"},
        {"method": "GET", "endpoint": "/aircrafts/{aircraft_code}"},
        {"method": "GET", "endpoint": "/airlines"},
        {"method": "GET", "endpoint": "/airlines/{airline_id}"},
        {"method": "GET", "endpoint": "/airports"},
        {"method": "GET", "endpoint": "/airports/{airport_code}"},
        {"method": "GET", "endpoint": "/cities"},
        {"method": "GET", "endpoint": "/cities/{city_code}"},
        {"method": "GET", "endpoint": "/flights/airport/{airport_code}"},
        {"method": "GET", "endpoint": "/flights"},
        {"method": "GET", "endpoint": "/flights/{limit}/{offset}"},
        {"method": "GET", "endpoint": "/flights/airport/{airport_code}/{limit}/{offset}"},
        {"method": "GET", "endpoint": "/flights/airport/{airport_code}/schedule/{scheduled_time_utc}/{limit}/{offset}"},
        {"method": "GET", "endpoint": "/flights/route/{departure_airport_code}/{arrival_airport_code}"},
        {"method": "GET", "endpoint": "/flights/route/{departure_airport_code}/{arrival_airport_code}/{limit}/{offset}"},
        {"method": "GET", "endpoint": "/schema/flights"},
        {"method": "GET", "endpoint": "/schema/countries"},
        {"method": "GET", "endpoint": "/schema/airports"},
        {"method": "GET", "endpoint": "/schema/cities"},
        {"method": "GET", "endpoint": "/schema/airlines"},
        {"method": "GET", "endpoint": "/schema/aircrafts"}
    ]
    return {"available_routes": routes}

@app.get("/countries")
async def get_countries(limit: int = 100, offset: int = 0):
    logging.info("Fetching all countries")
    query = {}
    return await fetch_records('countries', query, limit, offset)

@app.get("/countries/{country_code}")
async def get_country_by_code(country_code: str):
    logging.info(f"Fetching country with code {country_code}")
    query = {"country_code": country_code}
    return await fetch_record('countries', query)

@app.get("/aircrafts")
async def get_aircrafts(limit: int = 100, offset: int = 0):
    logging.info("Fetching all aircrafts")
    query = {}
    return await fetch_records('aircrafts', query, limit, offset)

@app.get("/aircrafts/{aircraft_code}")
async def get_aircraft_by_code(aircraft_code: str):
    logging.info(f"Fetching aircraft with code {aircraft_code}")
    query = {"aircraft_code": aircraft_code}
    return await fetch_record('aircrafts', query)

@app.get("/airlines")
async def get_airlines(limit: int = 100, offset: int = 0):
    logging.info("Fetching all airlines")
    query = {}
    return await fetch_records('airlines', query, limit, offset)

@app.get("/airlines/{airline_id}")
async def get_airline_by_id(airline_id: str):
    logging.info(f"Fetching airline with ID {airline_id}")
    query = {"airline_id": airline_id}
    return await fetch_record('airlines', query)

@app.get("/airports")
async def get_airports(limit: int = 100, offset: int = 0):
    logging.info("Fetching all airports")
    query = {}
    return await fetch_records('airports', query, limit, offset)

@app.get("/airports/{airport_code}")
async def get_airport_by_code(airport_code: str):
    logging.info(f"Fetching airport with code {airport_code}")
    query = {"airport_code": airport_code}
    return await fetch_record('airports', query)

@app.get("/cities")
async def get_cities(limit: int = 100, offset: int = 0):
    logging.info("Fetching all cities")
    query = {}
    return await fetch_records('cities', query, limit, offset)

@app.get("/cities/{city_code}")
async def get_city_by_code(city_code: str):
    logging.info(f"Fetching city with code {city_code}")
    query = {"city_code": city_code}
    return await fetch_record('cities', query)

@app.get("/flights/airport/{airport_code}")
async def get_flights_from_airport(airport_code: str, limit: int = 100, offset: int = 0):
    logging.info(f"Fetching flights from airport {airport_code} with limit {limit} and offset {offset}")
    query = {"airport_code": airport_code}
    return await fetch_records('departures', query, limit, offset)

@app.get("/flights")
async def get_all_flights(limit: int = 100, offset: int = 0):
    logging.info(f"Fetching all flights with limit {limit} and offset {offset}")
    query = {}
    return await fetch_records('departures', query, limit, offset)

@app.get("/flights/{limit}/{offset}")
async def get_all_flights_with_pagination(limit: int = 100, offset: int = 0):
    logging.info(f"Fetching all flights with limit {limit} and offset {offset}")
    query = {}
    return await fetch_records('departures', query, limit, offset)

@app.get("/flights/airport/{airport_code}/{limit}/{offset}")
async def get_flights_by_airport(airport_code: str, limit: int = 100, offset: int = 0):
    logging.info(f"Fetching flights from airport {airport_code} with limit {limit} and offset {offset}")
    query = {"airport_code": airport_code}
    return await fetch_records('departures', query, limit, offset)

@app.get("/flights/airport/{airport_code}/schedule/{scheduled_time_utc}/{limit}/{offset}")
async def get_flights_by_schedule(airport_code: str, scheduled_time_utc: str, limit: int = 100, offset: int = 0):
    logging.info(f"Fetching flights from airport {airport_code} at {scheduled_time_utc} with limit {limit} and offset {offset}")
    query = {
        "airport_code": airport_code,
        "ScheduledTimeUTC": scheduled_time_utc
    }
    return await fetch_records('departures', query, limit, offset)

@app.get("/flights/route/{departure_airport_code}/{arrival_airport_code}")
@app.get("/flights/route/{departure_airport_code}/{arrival_airport_code}/{limit}/{offset}")
async def get_flights_by_route(departure_airport_code: str, arrival_airport_code: str, limit: int = 100, offset: int = 0):
    logging.info(f"Fetching flights from {departure_airport_code} to {arrival_airport_code} with limit {limit} and offset {offset}")
    query = {
        "airport_code": departure_airport_code,
        "data.FlightStatusResource.Flights.Flight.Arrival.AirportCode": arrival_airport_code
    }
    return await fetch_records('departures', query, limit, offset)

@app.get("/schema/flights")
async def get_flights_schema():
    schema = {
        "departure_airport": "Code de l'aéroport de départ",
        "scheduled_departure_local": "Heure de départ prévue (heure locale)",
        "actual_departure_local": "Heure de départ réelle (heure locale)",
        "departure_terminal": "Terminal de départ",
        "flight_status_departure": "Statut du vol au départ",
        "arrival_airport": "Code de l'aéroport d'arrivée",
        "scheduled_arrival_local": "Heure d'arrivée prévue (heure locale)",
        "actual_arrival_local": "Heure d'arrivée réelle (heure locale)",
        "arrival_terminal": "Terminal d'arrivée",
        "flight_status_arrival": "Statut du vol à l'arrivée",
        "airline_id": "ID de la compagnie aérienne"
    }
    return schema

@app.get("/schema/countries")
async def get_countries_schema():
    schema = {
        "country_code": "Code du pays",
        "country_name": "Nom du pays"
    }
    return schema

@app.get("/schema/airports")
async def get_airports_schema():
    schema = {
        "airport_code": "Code de l'aéroport",
        "city_name": "Nom de la ville",
        "country_name": "Nom du pays"
    }
    return schema

@app.get("/schema/cities")
async def get_cities_schema():
    schema = {
        "city_code": "Code de la ville",
        "city_name": "Nom de la ville",
        "country_name": "Nom du pays"
    }
    return schema

@app.get("/schema/airlines")
async def get_airlines_schema():
    schema = {
        "airline_id": "ID de la compagnie aérienne",
        "airline_name": "Nom de la compagnie aérienne"
    }
    return schema

@app.get("/schema/aircrafts")
async def get_aircrafts_schema():
    schema = {
        "aircraft_code": "Code de l'aéronef",
        "aircraft_name": "Nom de l'aéronef"
    }
    return schema

@app.post("/predict")
async def predict(request: PredictionRequest):
    data = request.dict()

    # On prépare les données pour la prédiction
    df = pd.DataFrame([data])
    df = pd.get_dummies(df, columns=['airport_code', 'ArrivalAirportCode'])

    # On s'assure que toutes les colonnes nécessaires sont présentes
    model_columns = set(model.feature_names_in_)
    missing_cols = model_columns - set(df.columns)
    
    # Ajouter les colonnes manquantes en une seule opération
    for col in missing_cols:
        df[col] = 0

    # Re-organiser les colonnes pour correspondre à l'entraînement du modèle
    df = df[list(model_columns)]

    # On convertit la colonne datetime en timestamp
    df['DepartureScheduledTimeUTC'] = pd.to_datetime(df['DepartureScheduledTimeUTC']).astype(int) / 10**9

    # On fait la prédiction
    prediction = model.predict(df)

    # On renvoie la réponse JSON
    return {"departure_delay": prediction[0]}
