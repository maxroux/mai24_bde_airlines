from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import pandas as pd
import mlflow
import json
import os
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.compose import ColumnTransformer
import psycopg2
app = FastAPI()

# Fonction pour obtenir l'URI du modèle à partir de run_id.txt
def get_model_uri_from_run_id():
    try:
        with open("/shared/run_id.txt", "r") as f:
            run_id = f.read().strip()
        return f"runs:/{run_id}/models"
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Charger le modèle MLflow au démarrage de l'API
try:
    model_uri = get_model_uri_from_run_id()
    model = mlflow.pyfunc.load_model(model_uri)
except Exception as e:
    raise HTTPException(status_code=500, detail=str(e))

# Fonction pour charger les noms de fonctionnalités
def load_feature_names(filepath):
    try:
        with open(filepath, 'r') as f:
            feature_names = json.load(f)
        return feature_names
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

feature_names = load_feature_names('/shared/feature_names.json')

# Fonction pour charger les encodages de fréquences
def load_freq_encodings(filepath):
    try:
        with open(filepath, 'r') as f:
            freq_encodings = json.load(f)
        return freq_encodings
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

freq_encodings = load_freq_encodings('/shared/freq_encodings.json')

# Définir le modèle de données pour les requêtes de prédiction
class FlightData(BaseModel):
    departure_airport_code: str
    departure_time_status_code: str
    arrival_airport_code: str
    arrival_time_status_code: str
    marketing_airline_id: str
    aircraft_code: str
    flight_status_code: str
    departure_scheduled_hour: int
    departure_delay: float

# Fonction pour encoder les données d'entrée de manière cohérente
def preprocess_input(data_df):
    # Colonnes pour l'encodage one-hot et standardisation
    one_hot_cols = ['departure_time_status_code', 'arrival_time_status_code', 'flight_status_code']
    numeric_cols = ['departure_scheduled_hour', 'departure_delay']
    freq_cols = ['departure_airport_code', 'arrival_airport_code', 'marketing_airline_id', 'aircraft_code']

    # Appliquer les encodages de fréquence sauvegardés
    for col in freq_cols:
        data_df[col] = data_df[col].map(freq_encodings[col]).fillna(0)

    preprocessor = ColumnTransformer(
        transformers=[
            ('cat', OneHotEncoder(drop='first', sparse_output=False), one_hot_cols),
            ('num', StandardScaler(), numeric_cols),
            ('freq', 'passthrough', freq_cols)
        ], remainder='passthrough')

    data_preprocessed = preprocessor.fit_transform(data_df)

    one_hot_feature_names = preprocessor.named_transformers_['cat'].get_feature_names_out(one_hot_cols)
    all_feature_names = list(one_hot_feature_names) + numeric_cols + freq_cols
    data_preprocessed = pd.DataFrame(data_preprocessed, columns=all_feature_names)

    for feature in feature_names:
        if feature not in data_preprocessed.columns:
            data_preprocessed[feature] = 0

    data_preprocessed = data_preprocessed[feature_names]

    return data_preprocessed

# Endpoint pour faire des prédictions
@app.post("/predict")
def predict(data: FlightData):
    data_dict = data.dict()
    data_df = pd.DataFrame([data_dict])
    
    data_preprocessed = preprocess_input(data_df)
    
    prediction = model.predict(data_preprocessed)
    
    return {"prediction": prediction[0]}

# Connexion à la base de données PostgreSQL
def get_db_connection():
    conn = psycopg2.connect(
        dbname="airport_management",
        user="postgres",
        password="mysecretpassword",
        host="localhost",
        port="5432"
    )
    return conn

# Endpoint pour récupérer la liste des aéroports
@app.get("/airports")
def get_airports():
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    cursor.execute("SELECT * FROM airports")
    airports = cursor.fetchall()
    cursor.close()
    conn.close()
    return airports

# Endpoint pour récupérer la liste des compagnies aériennes
@app.get("/airlines")
def get_airlines():
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    cursor.execute("SELECT * FROM airlines")
    airlines = cursor.fetchall()
    cursor.close()
    conn.close()
    return airlines

# Endpoint pour récupérer la liste des pays
@app.get("/countries")
def get_countries():
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    cursor.execute("SELECT * FROM countries")
    countries = cursor.fetchall()
    cursor.close()
    conn.close()
    return countries

# Endpoint pour récupérer la liste des villes
@app.get("/cities")
def get_cities():
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    cursor.execute("SELECT * FROM cities")
    cities = cursor.fetchall()
    cursor.close()
    conn.close()
    return cities

# Endpoint pour récupérer la liste des aéronefs
@app.get("/aircrafts")
def get_aircrafts():
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    cursor.execute("SELECT * FROM aircrafts")
    aircrafts = cursor.fetchall()
    cursor.close()
    conn.close()
    return aircrafts

