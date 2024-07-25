import os
import json
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.ensemble import RandomForestRegressor
from sklearn.linear_model import LinearRegression, Ridge, Lasso
from sklearn.svm import SVR
from lightgbm import LGBMRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
import numpy as np
import mlflow
import mlflow.sklearn
from mlflow import log_metric, log_param, log_artifacts
import warnings
warnings.filterwarnings("ignore")


def load_data(file_path):
    with open(file_path, 'r') as file:
        data = json.load(file)
    return data

def extract_flights_data(data):
    flights_data = []
    for obj in data:
        flights = obj['data']['FlightStatusResource']['Flights']['Flight']
        for flight in flights:
            departure = flight.get('Departure', {})
            arrival = flight.get('Arrival', {})
            marketing_carrier = flight.get('MarketingCarrier', {})
            operating_carrier = flight.get('OperatingCarrier', {})
            equipment = flight.get('Equipment', {})
            flight_status = flight.get('FlightStatus', {})
            
            flight_info = {
                'departure_airport_code': departure.get('AirportCode', None),
                'departure_scheduled_time_local': departure.get('ScheduledTimeLocal', {}).get('DateTime', None),
                'departure_scheduled_time_utc': departure.get('ScheduledTimeUTC', {}).get('DateTime', None),
                'departure_actual_time_local': departure.get('ActualTimeLocal', {}).get('DateTime', None),
                'departure_actual_time_utc': departure.get('ActualTimeUTC', {}).get('DateTime', None),
                'departure_time_status_code': departure.get('TimeStatus', {}).get('Code', None),
                'departure_time_status_definition': departure.get('TimeStatus', {}).get('Definition', None),
                'arrival_airport_code': arrival.get('AirportCode', None),
                'arrival_scheduled_time_local': arrival.get('ScheduledTimeLocal', {}).get('DateTime', None),
                'arrival_scheduled_time_utc': arrival.get('ScheduledTimeUTC', {}).get('DateTime', None),
                'arrival_actual_time_local': arrival.get('ActualTimeLocal', {}).get('DateTime', None),
                'arrival_actual_time_utc': arrival.get('ActualTimeUTC', {}).get('DateTime', None),
                'arrival_time_status_code': arrival.get('TimeStatus', {}).get('Code', None),
                'arrival_time_status_definition': arrival.get('TimeStatus', {}).get('Definition', None),
                'marketing_airline_id': marketing_carrier.get('AirlineID', None),
                'marketing_flight_number': marketing_carrier.get('FlightNumber', None),
                'operating_airline_id': operating_carrier.get('AirlineID', None),
                'operating_flight_number': operating_carrier.get('FlightNumber', None),
                'aircraft_code': equipment.get('AircraftCode', None),
                'aircraft_registration': equipment.get('AircraftRegistration', None),
                'flight_status_code': flight_status.get('Code', None),
                'flight_status_definition': flight_status.get('Definition', None),
                'service_type': flight.get('ServiceType', None)
            }
            
            flights_data.append(flight_info)
    return pd.DataFrame(flights_data)

def preprocess_data(df):
    time_columns = ['departure_scheduled_time_utc', 'departure_actual_time_utc',
                    'arrival_scheduled_time_utc', 'arrival_actual_time_utc']
    for col in time_columns:
        df[col] = pd.to_datetime(df[col])
    
    df.loc[(df['departure_time_status_code'] == 'OT') & df['departure_actual_time_utc'].isna(), 'departure_actual_time_utc'] = df['departure_scheduled_time_utc']
    df.loc[(df['arrival_time_status_code'] == 'OT') & df['arrival_actual_time_utc'].isna(), 'arrival_actual_time_utc'] = df['arrival_scheduled_time_utc']
    
    df['departure_delay'] = (df['departure_actual_time_utc'] - df['departure_scheduled_time_utc']).dt.total_seconds() / 60
    df['arrival_delay'] = (df['arrival_actual_time_utc'] - df['arrival_scheduled_time_utc']).dt.total_seconds() / 60
    
    df['departure_scheduled_hour'] = df['departure_scheduled_time_utc'].dt.hour
    df['arrival_scheduled_hour'] = df['arrival_scheduled_time_utc'].dt.hour
    
    columns_to_keep = ['departure_airport_code', 'departure_time_status_code', 
                       'arrival_airport_code', 'arrival_time_status_code',
                       'marketing_airline_id', 'aircraft_code', 'flight_status_code',
                       'departure_scheduled_hour', 'arrival_scheduled_hour', 'departure_delay', 'arrival_delay']
    
    df = df[columns_to_keep]
    
    df = df.dropna(subset=['departure_delay', 'arrival_delay'])
    
    return df

def frequency_encoding(df, column):
    freq_encoding = df[column].value_counts() / len(df)
    df[column] = df[column].map(freq_encoding)
    return df, freq_encoding.to_dict()

def prepare_features(df):
    freq_cols = ['departure_airport_code', 'arrival_airport_code', 'marketing_airline_id', 'aircraft_code']
    freq_encodings = {}
    for col in freq_cols:
        df, encoding = frequency_encoding(df, col)
        freq_encodings[col] = encoding

    X = df.drop(columns=['arrival_delay'])
    y = df['arrival_delay']

    one_hot_cols = ['departure_time_status_code', 'arrival_time_status_code', 'flight_status_code']
    numeric_cols = ['departure_scheduled_hour', 'departure_delay']

    preprocessor = ColumnTransformer(
        transformers=[
            ('cat', OneHotEncoder(drop='first', sparse_output=False), one_hot_cols),
            ('num', StandardScaler(), numeric_cols),
            ('freq', 'passthrough', freq_cols)
        ])

    X_preprocessed = preprocessor.fit_transform(X)

    one_hot_feature_names = preprocessor.named_transformers_['cat'].get_feature_names_out(one_hot_cols)
    all_feature_names = list(one_hot_feature_names) + numeric_cols + freq_cols
    X_preprocessed = pd.DataFrame(X_preprocessed, columns=all_feature_names)

    return X_preprocessed, y, preprocessor, freq_encodings

def evaluate_model(model, X_train, y_train, X_test, y_test):
    model.fit(X_train, y_train)
    y_pred = model.predict(X_test)
    mae = mean_absolute_error(y_test, y_pred)
    mse = mean_squared_error(y_test, y_pred)
    rmse = np.sqrt(mse)
    r2 = r2_score(y_test, y_pred)
    return {'model': model, 'mae': mae, 'mse': mse, 'rmse': rmse, 'r2': r2}

def main(file_path):
    data = load_data(file_path)
    df = extract_flights_data(data)
    df = preprocess_data(df)

    X, y, preprocessor, freq_encodings = prepare_features(df)

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    models = [
        RandomForestRegressor(n_estimators=100, random_state=42),
        LinearRegression(),
        Ridge(alpha=1.0),
        Lasso(alpha=0.1),
        SVR(kernel='rbf', C=100, gamma=0.1, epsilon=.1),
        LGBMRegressor(n_estimators=100, learning_rate=0.1, verbose=-1)
    ]

    mlflow.set_tracking_uri("http://mlflow:5000")
    mlflow.set_experiment("Flight_Delays_Models")

    best_model = None
    best_mae = float('inf')
    best_result = None

    for model in models:
        result = evaluate_model(model, X_train, y_train, X_test, y_test)
        if result['mae'] < best_mae:
            best_mae = result['mae']
            best_model = model
            best_result = result
    
    with mlflow.start_run(run_name=f"Best_Model_{best_model.__class__.__name__}") as run:
        mlflow.log_params(best_model.get_params())
        mlflow.log_metrics({
            'mae': best_result['mae'],
            'mse': best_result['mse'],
            'rmse': best_result['rmse'],
            'r2': best_result['r2']
        })

        mlflow.sklearn.log_model(best_model, artifact_path="models")

        run_id = run.info.run_id
        os.makedirs('/shared', exist_ok=True)
        with open('/shared/run_id.txt', 'w') as f:
            f.write(run_id)
        
        # Save the preprocessor
        mlflow.sklearn.log_model(preprocessor, artifact_path="preprocessor")
        
        feature_names = list(X.columns)
        with open('/shared/feature_names.json', 'w') as f:
            json.dump(feature_names, f)
        
        # Save frequency encodings
        with open('/shared/freq_encodings.json', 'w') as f:
            json.dump(freq_encodings, f)

        print(f"Logged best model {best_model.__class__.__name__} with MAE: {best_mae}")
        print(f"Run ID {run_id} has been written to run_id.txt")

file_path = 'mongodbdata.json'
main(file_path)

