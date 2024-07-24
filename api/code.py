from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import mlflow
import mlflow.sklearn
import pandas as pd
import os
import pandas as pd
from sklearn.preprocessing import OneHotEncoder
import joblib
appe = FastAPI()

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
logged_model ='runs:/e18e7b3ff8ab43aba4fc5ad77bd4fd73/Random Forest'


# Load model as a PyFuncModel.
model = mlflow.pyfunc.load_model(logged_model)
encoder_path = "/app/onehotencoder.pkl"
encoder = joblib.load(encoder_path)
path= "/app/columns_ecd.pkl"
encoded_columns = joblib.load(path)
@appe.get("/")
def read_root():
    return {"message": "Bienvenue dans l'API de prédiction!"}

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
