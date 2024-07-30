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

# Connexion à MongoDB pour récupérer le model_uri
client = MongoClient(MONGO_URI)
db = client[DB_NAME]
collection = db[COLLECTION_NAME]

# Variables globales pour stocker le modèle et les préprocesseurs
model = None
preprocessor = None
freq_encodings = {}
feature_names = []

def load_initial_data(run_id):
    global freq_encodings, feature_names
    try:
        artifact_path = os.path.join(MLFLOW_ARTIFACT_URI, run_id, "artifacts")

        freq_encodings_path = os.path.join(artifact_path, "freq_encodings.pkl")
        with open(freq_encodings_path, 'rb') as f:
            freq_encodings = pickle.load(f)
        
        feature_names_path = os.path.join(artifact_path, "feature_names.pkl")
        with open(feature_names_path, 'rb') as f:
            feature_names = pickle.load(f)
    except Exception as e:
        logger.error(f"Error loading initial data: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to load initial data: {str(e)}")

def find_latest_run_id(artifact_root):
    """
    Trouve le plus récent dossier de run_id dans le répertoire des artefacts.
    """
    try:
        run_ids = [d for d in os.listdir(artifact_root) if os.path.isdir(os.path.join(artifact_root, d))]
        run_ids = sorted(run_ids, key=int, reverse=True)  # Trier par ordre décroissant pour obtenir le plus récent
        if not run_ids:
            raise HTTPException(status_code=500, detail="No run IDs found in artifact directory")
        return run_ids[0]
    except Exception as e:
        logger.error(f"Error finding latest run_id: {e}")
        raise HTTPException(status_code=500, detail="Failed to find latest run ID")

def load_latest_model():
    global model, preprocessor
    model_doc = collection.find_one({"model": "best_model"})
    if not model_doc or "uri" not in model_doc:
        raise HTTPException(status_code=500, detail="Model information not found in the database")
    
    try:
        # Déterminer le sous-dossier le plus récent dans mlartifacts
        run_id = find_latest_run_id(MLFLOW_ARTIFACT_URI)
        logger.info(f"Using run ID: {run_id}")

        # Construire le chemin local complet pour le modèle et le préprocesseur
        local_model_path = os.path.join(MLFLOW_ARTIFACT_URI, run_id, "artifacts", "models")
        local_preprocessor_path = os.path.join(MLFLOW_ARTIFACT_URI, run_id, "artifacts", "preprocessor")

        # Charger le modèle et le préprocesseur depuis le système de fichiers local
        model = mlflow.pyfunc.load_model(local_model_path)
        preprocessor = mlflow.pyfunc.load_model(local_preprocessor_path)
        
        load_initial_data(run_id)
        logger.info(f"Loaded new model from {local_model_path}")
    except Exception as e:
        logger.error(f"Error loading model: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to load model: {str(e)}")

# Charger le modèle au démarrage de l'application
@app.on_event("startup")
async def startup_event():
    load_latest_model()
    
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
        input_data = prepare_input_data(flight_data)
        processed_data = preprocessor.transform(input_data)
        prediction = model.predict(processed_data)
        return {"predicted_delay": float(prediction[0])}
    except Exception as e:
        logger.error(f"Error in prediction: {e}")
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
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=9544)
