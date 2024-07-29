from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.mongo.hooks.mongo import MongoHook
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from datetime import datetime, timedelta
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.linear_model import LinearRegression, Ridge, Lasso
from sklearn.svm import SVR
from lightgbm import LGBMRegressor
from xgboost import XGBRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error
from sklearn.model_selection import RandomizedSearchCV
import numpy as np
import mlflow
import mlflow.sklearn
import json
import logging
from prometheus_client import CollectorRegistry, Gauge, push_to_gateway

MLFLOW_TRACKING_URI = "http://mlflow:5000"

# Déclaration du DAG avec des paramètres de base
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2023, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'flight_delays_prediction',
    default_args=default_args,
    description='Machine Learning',
    # schedule_interval=timedelta(days=1),
    schedule_interval=timedelta(days=1),
    catchup=False,
    tags=['machine_learning']
)

# Fonction pour charger les données depuis MongoDB
def load_data_from_mongodb():
    mongo_conn_id = 'api_calls_mongodb'
    mongo_hook = MongoHook(conn_id=mongo_conn_id)
    collection = mongo_hook.get_collection('departures', 'airline_project')
    data = list(collection.find())
    return data

def extract_flights_data(data):
    flights_data = []
    for obj in data:
        flights = obj.get('data', {}).get('FlightStatusResource', {}).get('Flights', {}).get('Flight', [])
        for flight in flights:
            if isinstance(flight, dict):
                departure = flight.get('Departure', {})
                arrival = flight.get('Arrival', {})
                marketing_carrier = flight.get('MarketingCarrier', {})
                operating_carrier = flight.get('OperatingCarrier', {})
                equipment = flight.get('Equipment', {})

                flight_info = {
                    'departure_airport_code': departure.get('AirportCode', None),
                    'departure_scheduled_time_utc': departure.get('ScheduledTimeUTC', {}).get('DateTime', None),
                    'departure_actual_time_utc': departure.get('ActualTimeUTC', {}).get('DateTime', None),
                    'arrival_airport_code': arrival.get('AirportCode', None),
                    'arrival_scheduled_time_utc': arrival.get('ScheduledTimeUTC', {}).get('DateTime', None),
                    'arrival_actual_time_utc': arrival.get('ActualTimeUTC', {}).get('DateTime', None),
                    'departure_time_status_code': departure.get('TimeStatus', {}).get('Code', None),
                    'arrival_time_status_code': arrival.get('TimeStatus', {}).get('Code', None),
                    'marketing_airline_id': marketing_carrier.get('AirlineID', 'Unknown'),
                    'operating_airline_id': operating_carrier.get('AirlineID', 'Unknown'),
                    'aircraft_code': equipment.get('AircraftCode', 'Unknown')
                }

                flights_data.append(flight_info)
    return pd.DataFrame(flights_data)

def preprocess_data(df):
    # Conversion des dates en datetime
    time_columns = ['departure_scheduled_time_utc', 'departure_actual_time_utc',
                    'arrival_scheduled_time_utc', 'arrival_actual_time_utc']
    for col in time_columns:
        df[col] = pd.to_datetime(df[col], errors='coerce')

    # Remplir les valeurs manquantes pour les vols "On Time"
    df.loc[(df['departure_time_status_code'] == 'OT') & df['departure_actual_time_utc'].isna(), 'departure_actual_time_utc'] = df['departure_scheduled_time_utc']
    df.loc[(df['arrival_time_status_code'] == 'OT') & df['arrival_actual_time_utc'].isna(), 'arrival_actual_time_utc'] = df['arrival_scheduled_time_utc']

    # Calcul des retards
    df['departure_delay'] = (df['departure_actual_time_utc'] - df['departure_scheduled_time_utc']).dt.total_seconds() / 60
    df['arrival_delay'] = (df['arrival_actual_time_utc'] - df['arrival_scheduled_time_utc']).dt.total_seconds() / 60

    # Extraction des heures et des jours de la semaine
    df['departure_hour'] = df['departure_scheduled_time_utc'].dt.hour
    df['arrival_hour'] = df['arrival_scheduled_time_utc'].dt.hour
    df['departure_day_of_week'] = df['departure_scheduled_time_utc'].dt.dayofweek
    df['arrival_day_of_week'] = df['arrival_scheduled_time_utc'].dt.dayofweek

    # Création d'une feature route
    df['route'] = df['departure_airport_code'] + '-' + df['arrival_airport_code']

    # Sélectionner les colonnes pertinentes
    columns_to_keep = ['departure_airport_code', 'departure_time_status_code', 
                       'arrival_airport_code', 'arrival_time_status_code',
                       'departure_hour', 'arrival_hour', 'departure_day_of_week', 
                       'arrival_day_of_week', 'departure_delay', 'arrival_delay', 
                       'route', 'marketing_airline_id', 'operating_airline_id', 'aircraft_code']

    df = df[columns_to_keep]

    # Supprimer les lignes avec des valeurs NaN dans les retards
    df = df.dropna(subset=['departure_delay', 'arrival_delay'])

    return df

def frequency_encoding(df, column):
    freq_encoding = df[column].value_counts() / len(df)
    df[column] = df[column].map(freq_encoding)
    return df, freq_encoding.to_dict()

def prepare_features(df):
    # Colonnes à encoder par fréquence
    freq_cols = ['departure_airport_code', 'arrival_airport_code', 'route', 'marketing_airline_id', 'operating_airline_id', 'aircraft_code']
    freq_encodings = {}
    for col in freq_cols:
        df, encoding = frequency_encoding(df, col)
        freq_encodings[col] = encoding

    # Séparation des features et de la cible
    X = df.drop(columns=['arrival_delay'])
    y = df['arrival_delay']

    # Colonnes à encoder en one-hot
    one_hot_cols = ['departure_time_status_code', 'arrival_time_status_code']
    numeric_cols = ['departure_hour', 'arrival_hour', 'departure_day_of_week', 'departure_delay']

    # Préprocesseur pour les transformations
    preprocessor = ColumnTransformer(
        transformers=[
            ('cat', OneHotEncoder(drop='first', sparse_output=False), one_hot_cols),
            ('num', StandardScaler(), numeric_cols),
            ('freq', 'passthrough', freq_cols)
        ])

    X_preprocessed = preprocessor.fit_transform(X)

    # Obtenir les noms des features après transformation
    one_hot_feature_names = preprocessor.named_transformers_['cat'].get_feature_names_out(one_hot_cols)
    all_feature_names = list(one_hot_feature_names) + numeric_cols + freq_cols
    X_preprocessed = pd.DataFrame(X_preprocessed, columns=all_feature_names)

    return X_preprocessed, y, preprocessor, freq_encodings

# Initialisation du logger
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configuration de la registry de Prometheus
registry = CollectorRegistry()
mae_gauge = Gauge('model_mae', 'Mean Absolute Error of the model', ['model_name'], registry=registry)
rmse_gauge = Gauge('model_rmse', 'Root Mean Square Error of the model', ['model_name'], registry=registry)

# Fonction d'entraînement et d'évaluation du modèle
def train_and_evaluate_model(**kwargs):
    mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)
    mlflow.set_experiment("experimentation_ml_basique")

    df = extract_and_preprocess_data()
    X, y, preprocessor, freq_encodings = prepare_features(df)

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    models = [
        {
            'model': RandomForestRegressor(random_state=42),
            'params': {
                'n_estimators': [50, 100, 200],
                'max_depth': [None, 10, 20],
                'min_samples_split': [2, 5, 10]
            }
        },
        {
            'model': GradientBoostingRegressor(),
            'params': {
                'n_estimators': [50, 100, 200],
                'learning_rate': [0.01, 0.1, 0.2],
                'max_depth': [3, 5, 7]
            }
        },
        {
            'model': LinearRegression(),
            'params': {}
        },
        {
            'model': Ridge(),
            'params': {
                'alpha': [0.1, 1.0, 10.0]
            }
        },
        {
            'model': Lasso(),
            'params': {
                'alpha': [0.01, 0.1, 1.0]
            }
        },
        {
            'model': SVR(),
            'params': {
                'C': [0.1, 1, 10],
                'gamma': [0.001, 0.01, 0.1],
                'epsilon': [0.1, 0.2, 0.5]
            }
        },
        {
            'model': LGBMRegressor(),
            'params': {
                'n_estimators': [50, 100, 200],
                'learning_rate': [0.01, 0.1, 0.2],
                'num_leaves': [31, 50, 100]
            }
        },
        {
            'model': XGBRegressor(use_label_encoder=False, eval_metric='rmse'),
            'params': {
                'n_estimators': [50, 100, 200],
                'learning_rate': [0.01, 0.1, 0.2],
                'max_depth': [3, 5, 7]
            }
        }
    ]

    best_model = None
    best_mae = float('inf')
    best_result = None

    for model_dict in models:
        model = model_dict['model']
        params = model_dict['params']

        logger.info(f"Training model: {model.__class__.__name__}")
        logger.info(f"Params: {params}")
        try: 
            if params:
                search = RandomizedSearchCV(model, params, n_iter=10, cv=3, scoring='neg_mean_absolute_error', random_state=42)
                search.fit(X_train, y_train)
                best_estimator = search.best_estimator_
            else:
                best_estimator = model.fit(X_train, y_train)

            y_pred = best_estimator.predict(X_test)
            mae = mean_absolute_error(y_test, y_pred)
            mse = mean_squared_error(y_test, y_pred)
            rmse = np.sqrt(mse)
            
            logger.info(f"Model: {model.__class__.__name__}, MAE: {mae}, RMSE: {rmse}")

            if mae < best_mae:
                best_mae = mae
                best_model = best_estimator
                best_result = {'mae': mae, 'mse': mse, 'rmse': rmse}
    
            if best_result:
                update_metrics(model.__class__.__name__, best_mae, rmse)

            with mlflow.start_run(run_name=f"Best_Model_{best_model.__class__.__name__}") as run:
                mlflow.log_params(best_model.get_params())
                mlflow.log_metrics(best_result)
                mlflow.sklearn.log_model(best_model, artifact_path="models")
                mlflow.sklearn.log_model(preprocessor, artifact_path="preprocessor")

                model_uri = f"runs:/{run.info.run_id}/models"
                logger.info(f"Model URI: {model_uri}")

                save_model_uri_to_db(model_uri)
        
        except Exception as e:
            logger.error(f"Error training model {model.__class__.__name__}: {str(e)}")
            
    # Enregistrement des features et freq
    if best_result:
        s3_hook = S3Hook(aws_conn_id='aws_conn_id')
        s3_client = s3_hook.get_conn()
        s3_client.put_object(Bucket='datascientest-airline-project-bucket', Key='feature_names.json', Body=json.dumps(list(X.columns)))
        s3_client.put_object(Bucket='datascientest-airline-project-bucket', Key='freq_encodings.json', Body=json.dumps(freq_encodings))
    return model_uri

# Fonction pour mettre à jour les métriques avec le nom du modèle
def update_metrics(model_name, mae_value, rmse_value):
    mae_gauge.labels(model_name).set(mae_value)
    rmse_gauge.labels(model_name).set(rmse_value)
    push_to_gateway('pushgateway:9091', job='flight_delays', registry=registry)

# Fonction pour sauvegarder l'URI du modèle dans MongoDB
def save_model_uri_to_db(model_uri):
    mongo_conn_id = 'api_calls_mongodb'
    mongo_hook = MongoHook(conn_id=mongo_conn_id)
    collection = mongo_hook.get_collection('model_registry', 'airline_project')
    # Sauvegarder ou mettre à jour le document avec l'URI du modèle
    collection.update_one(
        {"model": "best_model"},
        {"$set": {"uri": model_uri}},
        upsert=True
    )

# Fonction pour extraire et prétraiter les données
def extract_and_preprocess_data():
    data = load_data_from_mongodb()
    df = extract_flights_data(data)
    df = preprocess_data(df)
    return df

# Fonction pour envoyer les données dans prometheus
def push_metrics_to_gateway():
    registry = CollectorRegistry()
    g = Gauge('example_metric', 'Description of metric', registry=registry)
    g.set(42)  # Remplacez cette valeur par votre métrique réelle

    # Poussez les métriques vers Pushgateway
    push_to_gateway('pushgateway:9091', job='airflow_dag', registry=registry)

# Définition des tâches Airflow
extract_and_preprocess_data_task = PythonOperator(
    task_id='extract_and_preprocess_data',
    python_callable=extract_and_preprocess_data,
    provide_context=True,
    dag=dag,
)

train_and_evaluate_model_task = PythonOperator(
    task_id='train_and_evaluate_model',
    python_callable=train_and_evaluate_model,
    provide_context=True,
    dag=dag,
)

push_metrics_to_gateway_task = PythonOperator(
    task_id='push_metrics_to_gateway',
    python_callable=push_metrics_to_gateway,
    provide_context=True,
    dag=dag,
)
# Définition de la dépendance entre les tâches
extract_and_preprocess_data_task >> train_and_evaluate_model_task >> push_metrics_to_gateway_task
