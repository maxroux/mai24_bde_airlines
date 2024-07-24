import os
import requests
import json
import numpy as np 
from pymongo import MongoClient
from datetime import datetime, timedelta
import pandas as pd
import psycopg2
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder
from sklearn.linear_model import LinearRegression
from sklearn.tree import DecisionTreeRegressor
from sklearn.ensemble import RandomForestRegressor
from sklearn.svm import SVR
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
import mlflow
import mlflow.sklearn
import joblib


mlflow_tracking_uri = os.getenv("MLFLOW_TRACKING_URI", "http://mlflow:5000")
mlflow.set_tracking_uri(mlflow_tracking_uri)
mlflow.set_experiment("airline_delay_prediction")

# MongoDB configuration
mongodb_client = MongoClient('mongodb://mongodb:27017/')
mongodb_db = mongodb_client['airline_status']
mongodb_collection = mongodb_db['status']

# PostgreSQL configuration
pg_conn = psycopg2.connect(
    dbname="reference",
    user="sirine",
    password="sirine",
    host="postgres",
    port="5432"
)
pg_cursor = pg_conn.cursor()

# Load data from MongoDB
documents = mongodb_collection.find()
data = []
for doc in documents:
    flights = doc['data']['FlightStatusResource']['Flights']['Flight']
    for flight in flights:
        departure = flight.get('Departure', {})
        arrival = flight.get('Arrival', {})
        marketing_carrier = flight.get('MarketingCarrier', {})
        data_dict = {
            'departure_airport': departure.get('AirportCode', ''),
            'scheduled_departure_local': departure['ScheduledTimeLocal']['DateTime'] if 'ScheduledTimeLocal' in departure else '',
            'actual_departure_local': departure['ActualTimeLocal']['DateTime'] if 'ActualTimeLocal' in departure else '',
            'departure_terminal': departure['Terminal'].get('Name', '') if 'Terminal' in departure else '',
            'flight_status_departure': departure['TimeStatus'].get('Definition', '') if 'TimeStatus' in departure else '',
            'arrival_airport': arrival.get('AirportCode', ''),
            'scheduled_arrival_local': arrival['ScheduledTimeLocal']['DateTime'] if 'ScheduledTimeLocal' in arrival else '',
            'actual_arrival_local': arrival['ActualTimeLocal']['DateTime'] if 'ActualTimeLocal' in arrival else '',
            'arrival_terminal': arrival['Terminal'].get('Name', '') if 'Terminal' in arrival else '',
            'flight_status_arrival': arrival['TimeStatus'].get('Definition', '') if 'TimeStatus' in arrival else '',
            'airline_id': marketing_carrier.get('AirlineID', '')
        }
        data.append(data_dict)

status_df = pd.DataFrame(data)
print(status_df)

# Load data from PostgreSQL
pg_cursor.execute("SELECT * FROM data_reference;")
colnames = [desc[0] for desc in pg_cursor.description]
rows = pg_cursor.fetchall()
static_df = pd.DataFrame(data=rows, columns=colnames)
pg_cursor.close()
pg_conn.close()

print(static_df)

# Merge data
static_df_selected = static_df[['airportcode', 'countryname', 'cityname']]
static_df_selected_departure = static_df_selected.rename(columns={'airportcode':'departure_airport', 'cityname': 'departure_cityname', 'countryname': 'departure_countryname'})
static_df_selected_arrival = static_df_selected.rename(columns={'airportcode':'arrival_airport', 'cityname': 'arrival_cityname', 'countryname': 'arrival_countryname'})
df_merged = pd.merge(status_df, static_df_selected_departure, on='departure_airport', how='left')
df = pd.merge(df_merged, static_df_selected_arrival, on='arrival_airport', how='left')

print(df.shape)

# Data preparation
print(df.isna().sum())
df1 = df[['arrival_airport', 'arrival_cityname', 'arrival_countryname']]
df1 = df1[df1['arrival_cityname'].isna()]
print(df1)

# Fill missing values
cityname = ['Erfurt', 'Tabuk', 'Gassim', 'Jizan', 'Batam', 'Multan', 'Alula', 'lichinga', 'Leeds', 'Eskişehir', 'Pékin', 'Nejran']
countryname = ['Allemagne', 'Arabie Saoudite', 'Arabie Saoudite', 'Arabie Saoudite', 'Indonésie', 'Pakistan', 'Inde', 'Mozambique', 'Royaume-Uni', 'Turquie', 'Chine', 'Arabie Saoudite']
arrival_airport_list = ['ERF', 'TUU', 'ELQ', 'GIZ', 'BTH', 'MUX', 'ULH', 'VXC', 'LBA', 'AOE', 'PKX', 'EAM']
arrival_airport_set = set(arrival_airport_list)

for index, row in df.iterrows():
    if row['arrival_airport'] in arrival_airport_set:
        idx = arrival_airport_list.index(row['arrival_airport'])
        df.at[index, 'arrival_cityname'] = cityname[idx]
        df.at[index, 'arrival_countryname'] = countryname[idx]

print(df.isna().sum())
print(df.duplicated().sum())
duplicates = df[df.duplicated(subset=df.columns, keep=False)]
print(duplicates[['departure_airport', 'actual_departure_local', 'arrival_airport']])
empty_columns = df.columns[df.eq('').any()]
empty_counts = df.eq('').sum()
print(empty_columns)
print(empty_counts)
print(df.shape)
df = df.drop(columns=['departure_terminal', 'arrival_terminal'])
print(df.shape)

df['actual_departure_local'] = pd.to_datetime(df['actual_departure_local'])
df['actual_arrival_local'] = pd.to_datetime(df['actual_arrival_local'])
df['scheduled_departure_local'] = pd.to_datetime(df['scheduled_departure_local'])
df['scheduled_arrival_local'] = pd.to_datetime(df['scheduled_arrival_local'])
print(df.dtypes)
df['departure_delay'] = df['actual_departure_local'] - df['scheduled_departure_local']
df['arrival_delay'] = df['actual_arrival_local'] - df['scheduled_arrival_local']
df['departure_delay'] = df['departure_delay'].dt.total_seconds() / 60
df['arrival_delay'] = df['arrival_delay'].dt.total_seconds() / 60
df['arrival_delay'].fillna(0, inplace=True)
df['departure_delay'].fillna(0, inplace=True)
df['arrival_delay'] = df['arrival_delay'].astype('int')
df['departure_delay'] = df['departure_delay'].astype('int')
columns_to_drop = ['actual_departure_local', 'actual_arrival_local', 'scheduled_departure_local', 'scheduled_arrival_local']
df = df.drop(columns=columns_to_drop)
print("voila le type des colonnes",df.dtypes)
for column in df.columns:
    unique_values = df[column].unique()
    print(f"Valeurs uniques dans la colonne '{column}': {unique_values}")
# Data splitting and encoding
X = df.drop('arrival_delay', axis=1)
y = df['arrival_delay']
print(y.unique())
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
print(X_train.columns)
h_encoder = OneHotEncoder(drop='first', sparse=False, handle_unknown='ignore')
cat = ['departure_airport', 'flight_status_departure', 'arrival_airport', 'flight_status_arrival', 'airline_id', 'departure_countryname', 'departure_cityname', 'arrival_countryname', 'arrival_cityname']
X_train_encoded = h_encoder.fit_transform(X_train[cat])
X_test_encoded = h_encoder.transform(X_test[cat])
X_train_encoded = pd.DataFrame(X_train_encoded, columns=h_encoder.get_feature_names_out(cat))
X_test_encoded = pd.DataFrame(X_test_encoded, columns=h_encoder.get_feature_names_out(cat))
X_train_encoded.index = X_train.index
X_test_encoded.index = X_test.index
X_train = X_train.drop(cat, axis=1)
X_test = X_test.drop(cat, axis=1)
X_train = pd.concat([X_train, X_train_encoded], axis=1)
X_test = pd.concat([X_test, X_test_encoded], axis=1)
path="/app/columns_ecd.pkl"
joblib.dump(h_encoder.get_feature_names_out(cat), path)
#training

models = {
    "Linear Regression": LinearRegression(),
    "Decision Tree": DecisionTreeRegressor(),
    "Random Forest": RandomForestRegressor(),
    "Support Vector Regressor": SVR()
}

best_model = None
best_score = float('-inf')

for name, model in models.items():
    with mlflow.start_run(run_name=name):
        model.fit(X_train, y_train)
        y_pred = model.predict(X_test)
        mae = mean_absolute_error(y_test, y_pred)
        mse = mean_squared_error(y_test, y_pred)
        rmse= np.sqrt(mse)
        r2 = r2_score(y_test, y_pred)
        
        mlflow.log_param("model_name", name)
        mlflow.log_metric("mae", mae)
        mlflow.log_metric("mse", mse)
        mlflow.log_metric("rmse",rmse)
        mlflow.log_metric("r2", r2)
        
        if r2 > best_score:
            best_score = r2
            best_model = model
        
        # Log the model
        mlflow.sklearn.log_model(model, name)
h_encoder_path = "/app/onehotencoder.pkl"
joblib.dump(h_encoder, h_encoder_path)
if best_model is not None:
    best_model_path = "/app/model.pkl"
    mlflow.sklearn.save_model(best_model, best_model_path)
    try:
        with mlflow.start_run(run_name="best_model"):
            mlflow.log_artifact(h_encoder_path)
            mlflow.log_artifact(best_model_path)
            print(f"Artifact enregistré à {best_model_path}")
    finally:
        mlflow.end_run()

