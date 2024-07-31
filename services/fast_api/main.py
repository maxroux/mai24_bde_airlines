import mlflow
from fastapi import FastAPI, HTTPException
from motor.motor_asyncio import AsyncIOMotorClient
from bson import ObjectId
import os
import logging
import pickle
import pandas as pd
from pydantic import BaseModel
from typing import List, Dict
from pymongo import MongoClient
from starlette.middleware import Middleware
from starlette_exporter import PrometheusMiddleware, handle_metrics

# Configuration des variables d'environnement
MONGO_URI = os.getenv('MONGO_URI', 'mongodb://airline:airline@mongodb:27017/')
DATABASE_NAME = os.getenv('DATABASE_NAME', 'airline_project')
COLLECTION_NAME_ML = "model_registry"

# Configuration de MLflow
MLFLOW_TRACKING_URI = "http://mlflow:5000"
mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)

# Configuration du logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configuration de la connexion MongoDB
client = AsyncIOMotorClient(MONGO_URI)
db = client[DATABASE_NAME]

# Initialisation de l'application FastAPI
app = FastAPI()

# Définir l'application FastAPI
app = FastAPI(
    middleware=[
        Middleware(PrometheusMiddleware, app_name="my_fastapi_app"),
    ]
)

class FlightData(BaseModel):
    departure_airport_code: str
    arrival_airport_code: str
    departure_scheduled_time_utc: str
    arrival_scheduled_time_utc: str
    marketing_airline_id: str
    operating_airline_id: str
    aircraft_code: str

# Fonction pour obtenir les informations sur le dernier modèle
def get_latest_model_info():
    try:
        client = MongoClient(MONGO_URI)
        db = client[DATABASE_NAME]
        collection = db[COLLECTION_NAME_ML]
        model_info = collection.find_one({"identifier": "best_model_overall"})
        if not model_info:
            raise ValueError("Aucune information sur le modèle n'a été trouvée dans la base de données.")
        return model_info
    except Exception as e:
        logger.error(f"Erreur lors de la récupération des informations du modèle : {str(e)}")
        raise
    finally:
        client.close()

# Fonction pour charger le modèle et les artefacts
def load_model_and_artifacts(run_id):
    try:
        model_uri = f"runs:/{run_id}/models"
        model = mlflow.pyfunc.load_model(model_uri)
        
        local_path = "./temp_artifacts"
        mlflow_client = mlflow.tracking.MlflowClient()  # Renommé pour éviter la confusion
        mlflow_client.download_artifacts(run_id, "artifacts", local_path)
        
        with open(os.path.join(local_path, "artifacts", "preprocessor.pkl"), "rb") as f:
            preprocessor = pickle.load(f)
        with open(os.path.join(local_path, "artifacts", "freq_encodings.pkl"), "rb") as f:
            freq_encodings = pickle.load(f)
        with open(os.path.join(local_path, "artifacts", "feature_names.pkl"), "rb") as f:
            feature_names = pickle.load(f)
        
        return model, preprocessor, freq_encodings, feature_names
    except Exception as e:
        logger.error(f"Erreur lors du chargement du modèle et des artefacts : {str(e)}")
        raise

def preprocess_input(input_data, preprocessor, freq_encodings, feature_names):
    try:
        # Si les colonnes ne sont pas présentes, les ajouter avec des valeurs par défaut
        if 'departure_time_status_code' not in input_data.columns:
            input_data['departure_time_status_code'] = 'NO'
        if 'arrival_time_status_code' not in input_data.columns:
            input_data['arrival_time_status_code'] = 'NO'
        if 'departure_delay' not in input_data.columns:
            input_data['departure_delay'] = 0
        if 'marketing_airline_id' not in input_data.columns:
            input_data['marketing_airline_id'] = "4Y"
        if 'operating_airline_id' not in input_data.columns:
            input_data['operating_airline_id'] = "4Y"
        if 'aircraft_code' not in input_data.columns:
            input_data['aircraft_code'] = "333"
            
        # Gestion des dates et heures
        input_data['departure_scheduled_time_utc'] = pd.to_datetime(input_data['departure_scheduled_time_utc'])
        input_data['arrival_scheduled_time_utc'] = pd.to_datetime(input_data['arrival_scheduled_time_utc'])
        input_data['departure_hour'] = input_data['departure_scheduled_time_utc'].dt.hour
        input_data['arrival_hour'] = input_data['arrival_scheduled_time_utc'].dt.hour
        input_data['departure_day_of_week'] = input_data['departure_scheduled_time_utc'].dt.dayofweek

        # Création de la route
        input_data['route'] = input_data['departure_airport_code'] + '-' + input_data['arrival_airport_code']

        # Appliquer les encodages de fréquence
        for col, encoding in freq_encodings.items():
            if col in input_data.columns:
                input_data[col] = input_data[col].map(encoding).fillna(0)

        processed_data = preprocessor.transform(input_data)
        return pd.DataFrame(processed_data, columns=feature_names)
    except Exception as e:
        logger.error(f"Erreur lors du prétraitement des données : {str(e)}")
        raise


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
        {"method": "GET", "endpoint": "/schema/aircrafts"},
        {"method": "POST", "endpoint": "/predict_delay"}
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

@app.get("/schema/predict_delay")
async def get_predict_delay_schema():
    schema = {
        "departure_airport_code": "Code de l'aéroport de départ",
        "arrival_airport_code": "Code de l'aéroport d'arrivée",
        "departure_scheduled_time_utc": "Heure de départ prévue en UTC",
        "arrival_scheduled_time_utc": "Heure d'arrivée prévue en UTC",
        "marketing_airline_id": "ID de la compagnie aérienne commerciale",
        "operating_airline_id": "ID de la compagnie aérienne opérant le vol",
        "aircraft_code": "Code de l'aéronef"
    }
    return schema


@app.post("/predict_delay")
async def predict_delay(flight_data: FlightData):
    try:
        # Conversion des données de l'entrée en DataFrame
        input_data = pd.DataFrame([flight_data.dict()])
        
        # Récupération des informations du modèle
        model_info = get_latest_model_info()
        run_id = model_info['run_id']
        model, preprocessor, freq_encodings, feature_names = load_model_and_artifacts(run_id)
        
        # Prétraitement des données d'entrée
        processed_input = preprocess_input(input_data, preprocessor, freq_encodings, feature_names)
        
        # Faire la prédiction
        predictions = model.predict(processed_input)
        
        return {"predicted_delay": predictions.tolist()}
    
    except Exception as e:
        logger.error(f"Erreur lors de la prédiction : {str(e)}")
        raise HTTPException(status_code=500, detail=f"Erreur lors de la prédiction : {str(e)}")


# Point de terminaison pour les métriques Prometheus
app.add_route("/metrics", handle_metrics)

# Point de départ de l'application
# if __name__ == "__main__":
#     import uvicorn
#     uvicorn.run(app, host="0.0.0.0", port=9544)