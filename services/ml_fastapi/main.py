import os
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import mlflow
import pandas as pd
import pickle
from pymongo import MongoClient
import logging

# Initialisation de l'application FastAPI
app = FastAPI()
logger = logging.getLogger(__name__)

# Configuration MongoDB et MLflow
MONGO_URI = "mongodb://airline:airline@localhost:27017/"
DB_NAME = "airline_project"
COLLECTION_NAME = "model_registry"
MLFLOW_TRACKING_URI = "http://localhost:5001"
MLFLOW_ARTIFACT_URI = "../mlflow_data/mlartifacts/"

# Définir le tracking URI de MLflow
mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)

# Chemins des fichiers de modèle et des artefacts
MODEL_PATH = "../mlflow_data/mlartifacts/2/f36215e46a344c2b9110e564dd450fdf/artifacts/models/model.pkl"
FEATURE_NAMES_PATH = "../../data/ml/f36215e46a344c2b9110e564dd450fdf/feature_names.pkl"
FREQ_ENCODINGS_PATH = "../../data/ml/f36215e46a344c2b9110e564dd450fdf/freq_encodings.pkl"
PREPROCESSOR_PATH = "../../data/ml/f36215e46a344c2b9110e564dd450fdf/preprocessor.pkl"

# Variables globales pour stocker le modèle et les préprocesseurs
model = None
freq_encodings = {}
feature_names = []

def load_model():
    global model
    try:
        logger.info(f"Chargement du modèle depuis : {MODEL_PATH}")
        with open(MODEL_PATH, 'rb') as f:
            model = pickle.load(f)
        logger.info("Modèle chargé avec succès.")
    except FileNotFoundError as e:
        logger.error(f"Fichier non trouvé : {MODEL_PATH}")
        raise HTTPException(status_code=500, detail=f"Échec du chargement du modèle : {str(e)}")
    except Exception as e:
        logger.error(f"Erreur lors du chargement du modèle : {e}")
        raise HTTPException(status_code=500, detail=f"Échec du chargement du modèle : {str(e)}")

def load_artifacts():
    global freq_encodings, feature_names
    try:
        logger.info(f"Chargement des encodages de fréquence depuis : {FREQ_ENCODINGS_PATH}")
        with open(FREQ_ENCODINGS_PATH, 'rb') as f:
            freq_encodings = pickle.load(f)
        
        logger.info(f"Chargement des noms des features depuis : {FEATURE_NAMES_PATH}")
        with open(FEATURE_NAMES_PATH, 'rb') as f:
            feature_names = pickle.load(f)
        
        logger.info("Artefacts chargés avec succès.")
    except FileNotFoundError as e:
        logger.error(f"Fichier non trouvé : {e}")
        raise HTTPException(status_code=500, detail=f"Échec du chargement des artefacts : {str(e)}")
    except Exception as e:
        logger.error(f"Erreur lors du chargement des artefacts : {e}")
        raise HTTPException(status_code=500, detail=f"Échec du chargement des artefacts : {str(e)}")


# Chargement des préprocesseurs et des artefacts nécessaires
def load_preprocessor():
    global preprocessor
    try:
        logger.info(f"Chargement du préprocesseur depuis : {PREPROCESSOR_PATH}")
        with open(PREPROCESSOR_PATH, 'rb') as f:
            preprocessor = pickle.load(f)
        logger.info("Préprocesseur chargé avec succès.")
    except FileNotFoundError as e:
        logger.error(f"Fichier non trouvé : {PREPROCESSOR_PATH}")
        raise HTTPException(status_code=500, detail=f"Échec du chargement du préprocesseur : {str(e)}")
    except Exception as e:
        logger.error(f"Erreur lors du chargement du préprocesseur : {e}")
        raise HTTPException(status_code=500, detail=f"Échec du chargement du préprocesseur : {str(e)}")


@app.on_event("startup")
async def startup_event():
    load_model()
    load_artifacts()
    load_preprocessor()  
    
# Schéma de validation pour les données de vol
class FlightData(BaseModel):
    departure_airport_code: str
    arrival_airport_code: str
    departure_scheduled_time_utc: str
    arrival_scheduled_time_utc: str
    marketing_airline_id: str
    operating_airline_id: str
    aircraft_code: str

# Préparer les données d'entrée pour le modèle
def prepare_input_data(flight_data: FlightData):
    df = pd.DataFrame([flight_data.dict()])
    
    # Vérification des colonnes disponibles dans le DataFrame
    logger.info(f"Colonnes du DataFrame : {df.columns.tolist()}")

    # Conversion des dates
    df['departure_scheduled_time_utc'] = pd.to_datetime(df['departure_scheduled_time_utc'])
    df['arrival_scheduled_time_utc'] = pd.to_datetime(df['arrival_scheduled_time_utc'])
    
    # Extraction des caractéristiques temporelles
    df['departure_hour'] = df['departure_scheduled_time_utc'].dt.hour
    df['arrival_hour'] = df['arrival_scheduled_time_utc'].dt.hour
    df['departure_day_of_week'] = df['departure_scheduled_time_utc'].dt.dayofweek
    df['arrival_day_of_week'] = df['arrival_scheduled_time_utc'].dt.dayofweek
    
    # Création de la feature route
    df['route'] = df['departure_airport_code'] + '-' + df['arrival_airport_code']
    
    # Application de l'encodage par fréquence
    for col in freq_encodings:
        df[col] = df[col].map(freq_encodings.get(col, 0)).fillna(0)
    
    # Ajout des colonnes manquantes avec des valeurs par défaut
    for col in feature_names:
        if col not in df.columns:
            df[col] = 0
    
    return df[feature_names]

@app.post("/predict_delay")
async def predict_delay(flight_data: FlightData):
    try:
        # Préparation des données d'entrée
        input_data = prepare_input_data(flight_data)
        processed_data = preprocessor.transform(input_data)
        prediction = model.predict(processed_data)
        return {"predicted_delay": float(prediction[0])}
    except Exception as e:
        logger.error(f"Erreur lors de la prédiction : {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/redeploy")
async def redeploy_model():
    try:
        load_latest_model()
        return {"status": "Model reloaded successfully"}
    except Exception as e:
        logger.error(f"Error reloading model: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    # load_latest_model()
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=9544)
