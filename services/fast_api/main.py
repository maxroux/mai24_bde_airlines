from fastapi import FastAPI, HTTPException
from motor.motor_asyncio import AsyncIOMotorClient
from bson import ObjectId
import os
import logging
import pickle
import pandas as pd
from pydantic import BaseModel
from typing import List, Dict

# Configuration des variables d'environnement
MONGO_URI = os.getenv('MONGO_URI', 'mongodb://airline:airline@mongodb:27017/')
DATABASE_NAME = os.getenv('DATABASE_NAME', 'airline_project')

# Configuration de la connexion MongoDB
client = AsyncIOMotorClient(MONGO_URI)
db = client[DATABASE_NAME]

# Initialisation de l'application FastAPI
app = FastAPI()

# Configuration des logs
logging.basicConfig(level=logging.INFO)

def convertir_object_ids(records):
    """Convertir ObjectId en chaîne de caractères dans plusieurs enregistrements."""
    return [{**record, "_id": str(record["_id"])} if "_id" in record and isinstance(record["_id"], ObjectId) else record for record in records]

async def recuperer_enregistrements(nom_collection, requete, limite, decalage):
    """Récupérer des enregistrements de la collection MongoDB en fonction de la requête."""
    collection = db[nom_collection]
    logging.info(f"Requête MongoDB sur {nom_collection}: {requete}")
    try:
        records = await collection.find(requete).skip(decalage).limit(limite).to_list(length=limite)
        logging.info(f"{len(records)} enregistrements récupérés de {nom_collection}")
        if not records:
            logging.info("Aucun enregistrement trouvé")
            raise HTTPException(status_code=404, detail="Aucun enregistrement trouvé")
        return convertir_object_ids(records)
    except Exception as e:
        logging.error(f"Erreur lors de la récupération des enregistrements de {nom_collection}: {e}")
        raise HTTPException(status_code=500, detail="Erreur interne du serveur")

async def recuperer_enregistrement(nom_collection, requete):
    """Récupérer un enregistrement unique de la collection MongoDB en fonction de la requête."""
    collection = db[nom_collection]
    logging.info(f"Requête MongoDB sur {nom_collection}: {requete}")
    try:
        record = await collection.find_one(requete)
        if not record:
            logging.info("Aucun enregistrement trouvé")
            raise HTTPException(status_code=404, detail="Aucun enregistrement trouvé")
        return convertir_object_ids([record])[0]
    except Exception as e:
        logging.error(f"Erreur lors de la récupération de l'enregistrement de {nom_collection}: {e}")
        raise HTTPException(status_code=500, detail="Erreur interne du serveur")

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
    logging.info("Récupération de tous les pays")
    query = {}
    return await recuperer_enregistrements('countries', query, limit, offset)

@app.get("/countries/{country_code}")
async def get_country_by_code(country_code: str):
    logging.info(f"Récupération du pays avec le code {country_code}")
    query = {"country_code": country_code}
    return await recuperer_enregistrement('countries', query)

@app.get("/aircrafts")
async def get_aircrafts(limit: int = 100, offset: int = 0):
    logging.info("Récupération de tous les aéronefs")
    query = {}
    return await recuperer_enregistrements('aircrafts', query, limit, offset)

@app.get("/aircrafts/{aircraft_code}")
async def get_aircraft_by_code(aircraft_code: str):
    logging.info(f"Récupération de l'aéronef avec le code {aircraft_code}")
    query = {"aircraft_code": aircraft_code}
    return await recuperer_enregistrement('aircrafts', query)

@app.get("/airlines")
async def get_airlines(limit: int = 100, offset: int = 0):
    logging.info("Récupération de toutes les compagnies aériennes")
    query = {}
    return await recuperer_enregistrements('airlines', query, limit, offset)

@app.get("/airlines/{airline_id}")
async def get_airline_by_id(airline_id: str):
    logging.info(f"Récupération de la compagnie aérienne avec l'ID {airline_id}")
    query = {"airline_id": airline_id}
    return await recuperer_enregistrement('airlines', query)

@app.get("/airports")
async def get_airports(limit: int = 100, offset: int = 0):
    logging.info("Récupération de tous les aéroports")
    query = {}
    return await recuperer_enregistrements('airports', query, limit, offset)

@app.get("/airports/{airport_code}")
async def get_airport_by_code(airport_code: str):
    logging.info(f"Récupération de l'aéroport avec le code {airport_code}")
    query = {"airport_code": airport_code}
    return await recuperer_enregistrement('airports', query)

@app.get("/cities")
async def get_cities(limit: int = 100, offset: int = 0):
    logging.info("Récupération de toutes les villes")
    query = {}
    return await recuperer_enregistrements('cities', query, limit, offset)

@app.get("/cities/{city_code}")
async def get_city_by_code(city_code: str):
    logging.info(f"Récupération de la ville avec le code {city_code}")
    query = {"city_code": city_code}
    return await recuperer_enregistrement('cities', query)

@app.get("/flights/airport/{airport_code}")
async def get_flights_from_airport(airport_code: str, limit: int = 100, offset: int = 0):
    logging.info(f"Récupération des vols depuis l'aéroport {airport_code} avec une limite de {limit} et un décalage de {offset}")
    query = {"airport_code": airport_code}
    return await recuperer_enregistrements('departures', query, limit, offset)

@app.get("/flights")
async def get_all_flights(limit: int = 100, offset: int = 0):
    logging.info(f"Récupération de tous les vols avec une limite de {limit} et un décalage de {offset}")
    query = {}
    return await recuperer_enregistrements('departures', query, limit, offset)

@app.get("/flights/{limit}/{offset}")
async def get_all_flights_with_pagination(limit: int = 100, offset: int = 0):
    logging.info(f"Récupération de tous les vols avec une limite de {limit} et un décalage de {offset}")
    query = {}
    return await recuperer_enregistrements('departures', query, limit, offset)

@app.get("/flights/airport/{airport_code}/{limit}/{offset}")
async def get_flights_by_airport(airport_code: str, limit: int = 100, offset: int = 0):
    logging.info(f"Récupération des vols depuis l'aéroport {airport_code} avec une limite de {limit} et un décalage de {offset}")
    query = {"airport_code": airport_code}
    return await recuperer_enregistrements('departures', query, limit, offset)

@app.get("/flights/airport/{airport_code}/schedule/{scheduled_time_utc}/{limit}/{offset}")
async def get_flights_by_schedule(airport_code: str, scheduled_time_utc: str, limit: int = 100, offset: int = 0):
    logging.info(f"Récupération des vols depuis l'aéroport {airport_code} à {scheduled_time_utc} avec une limite de {limit} et un décalage de {offset}")
    query = {
        "airport_code": airport_code,
        "ScheduledTimeUTC": scheduled_time_utc
    }
    return await recuperer_enregistrements('departures', query, limit, offset)

@app.get("/flights/route/{departure_airport_code}/{arrival_airport_code}")
@app.get("/flights/route/{departure_airport_code}/{arrival_airport_code}/{limit}/{offset}")
async def get_flights_by_route(departure_airport_code: str, arrival_airport_code: str, limit: int = 100, offset: int = 0):
    logging.info(f"Récupération des vols de {departure_airport_code} à {arrival_airport_code} avec une limite de {limit} et un décalage de {offset}")
    query = {
        "airport_code": departure_airport_code,
        "data.FlightStatusResource.Flights.Flight.Arrival.AirportCode": arrival_airport_code
    }
    return await recuperer_enregistrements('departures', query, limit, offset)

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
