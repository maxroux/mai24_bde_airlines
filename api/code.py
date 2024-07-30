from fastapi import FastAPI, HTTPException ,Request, Response
from pydantic import BaseModel
import mlflow
import mlflow.sklearn
import pandas as pd
import os
import pandas as pd
from sklearn.preprocessing import OneHotEncoder
import joblib
import asyncpg
from pymongo import MongoClient
import asyncio
from typing import List
from bson import ObjectId
from prometheus_client import start_http_server, Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from prometheus_client.core import CollectorRegistry
from starlette.middleware.base import BaseHTTPMiddleware
from starlette_prometheus import metrics, PrometheusMiddleware
appe = FastAPI()
# Ajouter le middleware Prometheus pour collecter les métriques de requête
appe.add_middleware(PrometheusMiddleware)
# Définir les métriques
REQUEST_COUNT = Counter(
    "request_count", "Nombre total de requêtes HTTP", ["method", "endpoint"]
)
RESPONSE_TIME = Histogram(
    "response_time", "Temps de réponse des requêtes HTTP", ["method", "endpoint"]
)

# Définir le modèle des données d'entrée
class PredictionRequest(BaseModel):
    departure_airport:str
    flight_status_departure:str
    arrival_airport:str
    flight_status_arrival:str
    airline_id:str
    departure_countryname:str
    departure_cityname:str
    arrival_countryname:str
    arrival_cityname:str
    departure_delay:int
# Se connecter à MLflow Tracking Server
mlflow.set_tracking_uri("http://mlflow:5000")
logged_model ='runs:/1a65f6a12324487dbe1dbc5a55f602b4/Random Forest'
# Load model as a PyFuncModel.
model = mlflow.pyfunc.load_model(logged_model)
encoder_path = "/app/onehotencoder.pkl"
encoder = joblib.load(encoder_path)
path= "/app/columns_ecd.pkl"
encoded_columns = joblib.load(path)
# Connexion à PostgreSQL
async def connect_postgres():
    return await asyncpg.connect(user='sirine', password='sirine', database='reference', host='postgres')
# Connexion à MongoDB
mongo_client = MongoClient("mongodb://mongodb:27017/")
mongo_db = mongo_client["airline_status"]
mongo_collection = mongo_db["status"]

@appe.middleware("http")
async def add_metrics(request: Request, call_next):
    method = request.method
    endpoint = request.url.path
    REQUEST_COUNT.labels(method, endpoint).inc()
    with RESPONSE_TIME.labels(method, endpoint).time():
        response = await call_next(request)
    return response
@appe.get("/")
def read_root():
    return {"message": "Bienvenue dans l'API de prédiction!"}

# Définir la route pour les métriques
@appe.get("/metrics")
async def handle_metrics():
    data = generate_latest()
    return Response(content=data, media_type=CONTENT_TYPE_LATEST)

@appe.post("/predict")
def predict(request: PredictionRequest):
    try:
        # Convertir les données d'entrée en DataFrame
        input_data = pd.DataFrame([request.dict()])
        print("Données d'entrée avant encodage :")
        print(input_data)

        # Appliquer le OneHotEncoding
        categorical_columns = [
            'departure_airport', 'flight_status_departure', 'arrival_airport',
            'flight_status_arrival', 'airline_id', 'departure_countryname',
            'departure_cityname', 'arrival_countryname', 'arrival_cityname'
        ]
        # Extraire les colonnes catégorielles des données d'entrée
        categorical_data = input_data[categorical_columns]

        # Ajuster l'encodeur aux données et les transformer
        encoded_categorical_data = encoder.transform(categorical_data)

        # Convertir les données encodées en DataFrame
        encoded_categorical_df = pd.DataFrame(
            encoded_categorical_data,
            columns=encoded_columns
        )
        print("Colonnes encodées :")
        print(encoded_categorical_df.columns)
        # Supprimer les colonnes catégorielles d'origine des données d'entrée
        input_data = input_data.drop(columns=categorical_columns)

        # Ajouter les colonnes encodées aux données d'entrée
        input_data = pd.concat([input_data, encoded_categorical_df], axis=1)
        print("Données après encodage :")
        print(input_data)
        # Faire la prédiction 
        prediction = model.predict(input_data)

        # Retourner la prédiction
        return {"prediction": prediction[0]}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@appe.get("/postgres-data")
async def get_postgres_data():
    try:
        conn = await connect_postgres()
        rows = await conn.fetch("SELECT * FROM data_reference")
        await conn.close()
        return {"data": [dict(row) for row in rows]}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
def serialize_mongo_document(document):
    """Convertit les documents MongoDB en format JSON sérialisable."""
    document['_id'] = str(document['_id'])
    return document

@appe.get("/mongodb-data")
def get_mongodb_data():
    try:
        documents = list(mongo_collection.find())
        serialized_documents = [serialize_mongo_document(doc) for doc in documents]
        return {"data": serialized_documents}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

    
    
