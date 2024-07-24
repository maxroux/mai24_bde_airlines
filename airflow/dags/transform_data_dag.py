from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime, timedelta
import os
import pandas as pd
import json
from pymongo import MongoClient
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.linear_model import LinearRegression, Lasso, Ridge
from sklearn.svm import SVR
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
import joblib
import os

# Configuration du DAG Airflow
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 7, 22),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'flight_departure_pipeline',
    default_args=default_args,
    description='Pipeline pour le traitement des données de départs de vols et le ML',
    schedule_interval=timedelta(days=1),
)

# Fonction pour charger les données depuis MongoDB et les enregistrer dans un CSV
def load_data_from_mongodb():
    client = MongoClient('mongodb://airline:airline@mongodb:27017/')
    db = client['airline_project']
    collection = db['departures']
    data = list(collection.find({}))
    df = pd.DataFrame(data)
    df.to_csv('/opt/airflow/data/departures.csv', index=False)
    print("Data loaded and saved to CSV.")

# Fonction pour extraire les données pertinentes
def extract_data():
    df = pd.read_csv('/opt/airflow/data/departures.csv')
    extracted_data = []
    for _, row in df.iterrows():
        try:
            if isinstance(row['data'], str):
                data = json.loads(row['data'].replace("'", '"'))
            else:
                data = row['data']
            
            if 'FlightStatusResource' in data and 'Flights' in data['FlightStatusResource']:
                flights = data['FlightStatusResource']['Flights']['Flight']
                if not isinstance(flights, list):
                    flights = [flights]
                for flight in flights:
                    # Vérification du type avant l'accès
                    departure_time = flight['Departure'].get('ScheduledTimeUTC', {})
                    if isinstance(departure_time, dict):
                        scheduled_time_utc = departure_time.get('DateTime', "")
                    else:
                        scheduled_time_utc = departure_time
                    
                    arrival_time = flight['Arrival'].get('ScheduledTimeUTC', {})
                    if isinstance(arrival_time, dict):
                        arrival_time_utc = arrival_time.get('DateTime', "")
                    else:
                        arrival_time_utc = arrival_time
                    
                    extracted_data.append({
                        'airport_code': row['airport_code'],
                        'ScheduledTimeUTC': scheduled_time_utc,
                        'FlightNumber': flight['MarketingCarrier']['FlightNumber'],
                        'AirlineID': flight['MarketingCarrier']['AirlineID'],
                        'DepartureTimeUTC': scheduled_time_utc,
                        'ArrivalTimeUTC': arrival_time_utc,
                        'FlightStatus': flight.get('FlightStatus', {}).get('Code', 'Unknown'),
                        'Equipment': flight.get('Equipment', {}).get('AircraftCode', 'Unknown')
                    })
        except (json.JSONDecodeError, KeyError, TypeError) as e:
            print(f"Error processing row {row}: {e}")
    
    if extracted_data:
        pd.DataFrame(extracted_data).to_csv('/opt/airflow/data/extracted_data.csv', index=False)
        print("Data extracted and saved.")
    else:
        print("No data extracted, skipping CSV writing.")



# Fonction pour prétraiter les données
def preprocess_data():
    df = pd.read_csv('/opt/airflow/data/extracted_data.csv')
    df['ScheduledTimeUTC'] = pd.to_datetime(df['ScheduledTimeUTC'], errors='coerce')
    df['DepartureTimeUTC'] = pd.to_datetime(df['DepartureTimeUTC'], errors='coerce')
    df['ArrivalTimeUTC'] = pd.to_datetime(df['ArrivalTimeUTC'], errors='coerce')

    df['DepartureDelay'] = (df['DepartureTimeUTC'] - df['ScheduledTimeUTC']).dt.total_seconds() / 60.0
    df['ArrivalDelay'] = (df['ArrivalTimeUTC'] - df['ScheduledTimeUTC']).dt.total_seconds() / 60.0
    df.dropna(subset=['DepartureDelay', 'ArrivalDelay'], inplace=True)
    
    df.to_csv('/opt/airflow/data/preprocessed_data.csv', index=False)
    print("Data preprocessed and saved.")

# Fonction pour entraîner les modèles de machine learning
# Fonction pour entraîner les modèles de machine learning
def train_models():
    # Charger les données prétraitées
    df = pd.read_csv('/opt/airflow/data/preprocessed_data.csv')
    
    # Préparation des données pour l'entraînement
    X = df[['DepartureDelay']].values
    y = df['ArrivalDelay'].values
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    # Définition des modèles à entraîner
    models = {
        'RandomForest': RandomForestRegressor(),
        'LinearRegression': LinearRegression(),
        'Lasso': Lasso(),
        'Ridge': Ridge(),
        'SVR': SVR()
    }

    # Assurer que le répertoire de sauvegarde des modèles existe
    model_dir = '/opt/airflow/models/'
    os.makedirs(model_dir, exist_ok=True)

    results = {}
    for name, model in models.items():
        # Entraîner le modèle
        model.fit(X_train, y_train)
        
        # Prédictions sur le set de test
        y_pred = model.predict(X_test)
        
        # Calcul des métriques
        results[name] = {
            'MAE': mean_absolute_error(y_test, y_pred),
            'MSE': mean_squared_error(y_test, y_pred),
            'RMSE': mean_squared_error(y_test, y_pred, squared=False),
            'R2': r2_score(y_test, y_pred)
        }
        
        # Sauvegarder le modèle entraîné
        joblib.dump(model, os.path.join(model_dir, f'{name}.joblib'))
        print(f"Model {name} trained and saved.")
    
    # Identifier et afficher le meilleur modèle basé sur le RMSE
    best_model = min(results, key=lambda x: results[x]['RMSE'])
    print(f"Best model: {best_model} with RMSE: {results[best_model]['RMSE']}")


# Définition des tâches du DAG
load_data_task = PythonOperator(
    task_id='load_data_from_mongodb',
    python_callable=load_data_from_mongodb,
    dag=dag,
)

extract_data_task = PythonOperator(
    task_id='extract_data',
    python_callable=extract_data,
    dag=dag,
)

preprocess_data_task = PythonOperator(
    task_id='preprocess_data',
    python_callable=preprocess_data,
    dag=dag,
)

train_models_task = PythonOperator(
    task_id='train_models',
    python_callable=train_models,
    dag=dag,
)

# Définition de la séquence des tâches
load_data_task >> extract_data_task >> preprocess_data_task >> train_models_task

if __name__ == "__main__":
    # Permet d'exécuter le script hors de l'environnement Airflow pour les tests
    load_data_from_mongodb()
    extract_data()
    preprocess_data()
    train_models()
