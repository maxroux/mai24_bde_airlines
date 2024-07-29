from fastapi import FastAPI, HTTPException
from motor.motor_asyncio import AsyncIOMotorClient
from pydantic import BaseModel
import mlflow
import pandas as pd
import os
import json

# Configuration MongoDB
MONGO_URI = os.getenv('MONGO_URI', 'mongodb://airline:airline@localhost:27017/')
DATABASE_NAME = os.getenv('DATABASE_NAME', 'airline_project')
MODEL_COLLECTION = 'model_registry'
mlflow.set_tracking_uri("http://localhost:5001")

# Initialisation de FastAPI
app = FastAPI()

class PredictionRequest(BaseModel):
    airport_code: str
    DepartureScheduledTimeUTC: str
    ArrivalAirportCode: str

async def get_model_uri_from_db(db):
    """Récupère l'URI du modèle stocké dans MongoDB."""
    document = await db[MODEL_COLLECTION].find_one({'_id': 'latest_model'})
    if document and 'model_uri' in document:
        return document['model_uri']
    else:
        raise ValueError("Model URI not found in the database")

@app.on_event("startup")
async def startup_event():
    """Événement de démarrage pour établir les connexions et charger le modèle."""
    # Connexion à MongoDB
    app.state.client = AsyncIOMotorClient(MONGO_URI)
    app.state.db = app.state.client[DATABASE_NAME]
    try:
        # Charger l'URI du modèle et le modèle MLflow
        model_uri = await get_model_uri_from_db(app.state.db)
        app.state.model = mlflow.pyfunc.load_model(model_uri)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error loading model: {str(e)}")

@app.on_event("shutdown")
async def shutdown_event():
    """Événement de fermeture pour nettoyer les ressources."""
    app.state.client.close()

@app.post("/predict")
async def predict(request: PredictionRequest):
    """Endpoint de prédiction qui reçoit les données et retourne le retard de départ."""
    data = request.dict()

    # Préparer les données pour la prédiction
    df = pd.DataFrame([data])

    # Appliquer les encodages de fréquences pour les caractéristiques catégorielles
    # (Cette section doit être adaptée en fonction de votre pré-traitement spécifique)
    for col, encoding in freq_encodings.items():
        if col in df:
            df[col] = df[col].map(encoding).fillna(0)
        else:
            df[col] = 0  # Ajouter une colonne manquante avec des valeurs 0

    # Convertir la colonne datetime en timestamp
    df['DepartureScheduledTimeUTC'] = pd.to_datetime(df['DepartureScheduledTimeUTC']).astype(int) / 10**9

    # S'assurer que toutes les colonnes nécessaires sont présentes
    model_columns = set(feature_names)
    missing_cols = model_columns - set(df.columns)
    for col in missing_cols:
        df[col] = 0

    # Re-organiser les colonnes pour correspondre à l'entraînement du modèle
    df = df[list(model_columns)]

    # Faire la prédiction
    try:
        prediction = app.state.model.predict(df)
        return {"departure_delay": prediction[0]}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")

# Variables et fonctions de support
feature_names = [...]  # Charger les noms de fonctionnalités depuis un fichier ou une source
freq_encodings = {...}  # Charger les encodages de fréquences depuis un fichier ou une source


