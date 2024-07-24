# On importe les bibliothèques nécessaires
import requests
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_absolute_error
import time
import pickle

# On définit l'URL de base de l'API
base_url = 'https://api.domainelibre.com'

# On définit les paramètres pour la requête initiale
limit = 100
offset = 0

# On crée une liste pour stocker tous les vols
all_flights = []

# On initialise le compteur pour le nombre d'appels API
api_calls = 0

print("Début de la récupération des données...")

while True:
    # On définit les paramètres pour la requête
    params = {
        'limit': limit,
        'offset': offset
    }

    try:
        # On fait la requête GET pour récupérer les données des vols
        response = requests.get(f'{base_url}/flights', params=params)
        api_calls += 1

        # On vérifie si la requête a réussi
        if response.status_code == 200:
            flights_data = response.json()
            # On vérifie s'il y a des vols dans la réponse
            if not flights_data:
                break  # On sort de la boucle si aucune donnée supplémentaire n'est trouvée

            # On ajoute les nouveaux vols à la liste
            for record in flights_data:
                flight_data = record.get('data', {}).get('FlightStatusResource', {}).get('Flights', {}).get('Flight', [])
                for flight in flight_data:
                    flight_info = {
                        'ScheduledTimeUTC': flight.get('ScheduledTimeUTC'),
                        'airport_code': record.get('airport_code'),
                        'ArrivalAirportCode': flight.get('Arrival', {}).get('AirportCode'),
                        'ArrivalScheduledTimeUTC': flight.get('Arrival', {}).get('ScheduledTimeUTC', {}).get('DateTime'),
                        'ArrivalActualTimeUTC': flight.get('Arrival', {}).get('ActualTimeUTC', {}).get('DateTime'),
                        'DepartureAirportCode': flight.get('Departure', {}).get('AirportCode'),
                        'DepartureScheduledTimeUTC': flight.get('Departure', {}).get('ScheduledTimeUTC', {}).get('DateTime'),
                        'DepartureActualTimeUTC': flight.get('Departure', {}).get('ActualTimeUTC', {}).get('DateTime'),
                        'FlightStatus': flight.get('FlightStatus', {}).get('Definition')
                    }
                    all_flights.append(flight_info)
            
            # On incrémente l'offset pour la prochaine requête
            offset += limit
        else:
            print(f"Erreur lors de la récupération des données : {response.status_code}")
            break

    except requests.RequestException as e:
        print(f"Une erreur s'est produite : {e}")
        break

    # On ajoute un délai pour éviter de surcharger l'API
    time.sleep(1)

print(f"Nombre total d'appels API : {api_calls}")
print(f"Nombre total de vols récupérés : {len(all_flights)}")

# On convertit la liste en DataFrame
flights_df = pd.DataFrame(all_flights)

# On convertit les colonnes de temps en format datetime
flights_df['ScheduledTimeUTC'] = pd.to_datetime(flights_df['ScheduledTimeUTC'])
flights_df['ArrivalScheduledTimeUTC'] = pd.to_datetime(flights_df['ArrivalScheduledTimeUTC'])
flights_df['ArrivalActualTimeUTC'] = pd.to_datetime(flights_df['ArrivalActualTimeUTC'])
flights_df['DepartureScheduledTimeUTC'] = pd.to_datetime(flights_df['DepartureScheduledTimeUTC'])
flights_df['DepartureActualTimeUTC'] = pd.to_datetime(flights_df['DepartureActualTimeUTC'])

# On calcule les retards en minutes
flights_df['ArrivalDelay'] = (flights_df['ArrivalActualTimeUTC'] - flights_df['ArrivalScheduledTimeUTC']).dt.total_seconds() / 60
flights_df['DepartureDelay'] = (flights_df['DepartureActualTimeUTC'] - flights_df['DepartureScheduledTimeUTC']).dt.total_seconds() / 60

# On supprime les lignes avec des valeurs manquantes dans les colonnes de retard
flights_df = flights_df.dropna(subset=['ArrivalDelay', 'DepartureDelay'])

print(f"Nombre de vols après traitement (retards non nuls) : {len(flights_df)}")

# On sélectionne les caractéristiques et la cible
X = flights_df[['airport_code', 'DepartureScheduledTimeUTC', 'ArrivalAirportCode']]
y = flights_df['DepartureDelay']

# On encode les variables catégorielles
X = pd.get_dummies(X, columns=['airport_code', 'ArrivalAirportCode'])

# On convertit la colonne datetime en timestamp
X['DepartureScheduledTimeUTC'] = X['DepartureScheduledTimeUTC'].astype(int) / 10**9

# On divise les données en ensembles d'entraînement et de test
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# On crée une fonction pour évaluer différents modèles
def evaluate_model(model, X_train, X_test, y_train, y_test):
    model.fit(X_train, y_train)
    y_pred = model.predict(X_test)
    mae = mean_absolute_error(y_test, y_pred)
    return mae

# On initialise les modèles
models = {
    'RandomForest': RandomForestRegressor(n_estimators=100, random_state=42),
    'GradientBoosting': GradientBoostingRegressor(n_estimators=100, random_state=42),
    'LinearRegression': LinearRegression()
}

# On évalue chaque modèle
model_performance = {}
for name, model in models.items():
    mae = evaluate_model(model, X_train, X_test, y_train, y_test)
    model_performance[name] = mae

# On affiche les résultats
best_model_name = min(model_performance, key=model_performance.get)
best_model = models[best_model_name]
best_model_mae = model_performance[best_model_name]

print(f"Meilleur modèle: {best_model_name} avec une MAE de {best_model_mae} minutes")
print("Performance des autres modèles :")
for name, mae in model_performance.items():
    print(f"{name}: MAE = {mae} minutes")

print("Exemple de données traitées :")
print(flights_df.head())

# On picke le meilleur modèle
with open('best_model.pkl', 'wb') as model_file:
    pickle.dump(best_model, model_file)
