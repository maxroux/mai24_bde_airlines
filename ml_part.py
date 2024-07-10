from pymongo import MongoClient
import pandas as pd 
import psycopg2
import numpy as np
from sklearn import model_selection
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder,LabelEncoder
from sklearn.linear_model import LinearRegression
from sklearn.tree import DecisionTreeRegressor
from sklearn.ensemble import RandomForestRegressor
from sklearn.svm import SVR
from sklearn.metrics import mean_absolute_error,mean_squared_error,r2_score
from sklearn.impute import SimpleImputer
from sklearn.feature_selection import RFE


"""Connexion à MongoDB pour importer les données et les mettre dans un dataframe"""
client = MongoClient('mongodb://localhost:27017/')
db = client['airline_project']  
collection = db['airline']  
# Requête pour récupérer tous les documents
documents = collection.find()
# Liste pour stocker tous les documents
data = []
# Itération sur le curseur et ajout des documents à la liste
for doc in documents:
    flights=doc['data']['FlightStatusResource']['Flights']['Flight']
    for flight in flights:
            departure = flight.get('Departure', {})
            arrival = flight.get('Arrival', {})
            marketing_carrier = flight.get('MarketingCarrier', {})
            equipment = flight.get('Equipment', {})
            flight_status = flight.get('FlightStatus', {})
            
            # Création d'un dictionnaire avec les informations pertinentes
            data_dict = {
                'departure_airport': departure.get('AirportCode', ''),
                'scheduled_departure_local': departure['ScheduledTimeLocal']['DateTime'] if 'ScheduledTimeLocal' in departure else '',
                'actual_departure_local': departure['ActualTimeLocal']['DateTime'] if 'ActualTimeLocal' in departure else '',
                'departure_terminal': departure['Terminal'].get('Name', '') if 'Terminal' in departure else '',
                'flight_status_departure':departure['TimeStatus'].get('Definition','')if 'TimeStatus' in departure else '',
                'arrival_airport': arrival.get('AirportCode', ''),
                'scheduled_arrival_local': arrival['ScheduledTimeLocal']['DateTime'] if 'ScheduledTimeLocal' in arrival else '',
                'actual_arrival_local': arrival['ActualTimeLocal']['DateTime'] if 'ActualTimeLocal' in arrival else '',
                'arrival_terminal': arrival['Terminal'].get('Name', '') if 'Terminal' in arrival else '',
                'flight_status_arrival':arrival['TimeStatus'].get('Definition','')if 'TimeStatus' in arrival else '',
                'airline_id': marketing_carrier.get('AirlineID', '')
            }
            
            # Ajout du dictionnaire à la liste des données
            data.append(data_dict)

# Création du DataFrame à partir de la liste (données de flight_status)
status_df = pd.DataFrame(data)
print(status_df)

"""Connexion à la base de données PostgreSQL pour importer les données statiques """
conn = psycopg2.connect(
    dbname="airline_project",
    user="postgres",
    password="sirine",
    host="localhost",
    port="5432"
)
# Création d'un curseur pour exécuter des requêtes SQL
cursor = conn.cursor()
# Requête SQL pour extraire une table 
query = "SELECT * FROM data_reference;"
# Exécution de la requête
cursor.execute(query)
# Récupération des résultats
colnames = [desc[0] for desc in cursor.description]#recuperation du noms de colones
rows = cursor.fetchall()
static_df=pd.DataFrame(data=rows,columns=colnames)
cursor.close()
print(static_df)
conn.close()

"""jointure entre table static_df et status_df pour construire base de données final pour mlpart"""
static_df_selected=static_df[['airportcode','countryname','cityname']]
static_df_selected_departure=static_df_selected.rename(columns={'airportcode':'departure_airport','cityname': 'departure_cityname', 'countryname': 'departure_countryname'})
static_df_selected_arrival=static_df_selected.rename(columns={'airportcode':'arrival_airport','cityname': 'arrival_cityname', 'countryname': 'arrival_countryname'})
df_merged=pd.merge(status_df,static_df_selected_departure,on='departure_airport',how='left')
df=pd.merge(df_merged,static_df_selected_arrival,on='arrival_airport',how='left')#notre base de données final pour la partie machine learning 
print(df.shape)


"""préparation de notre base de données"""

#verification des valeurs manquantes 
print(df.isna().sum())
df1=df[['arrival_airport','arrival_cityname','arrival_countryname']]
df1=df1[df1['arrival_cityname'].isna()]
print (df1)
#remplacement des valeurs manquantes 
cityname=['Erfurt', 'Tabuk', 'Gassim', 'Jizan', 'Batam', 'Multan', 'Alula', 'lichinga', 'Leeds', 'Eskişehir', 'Pékin', 'Nejran']
countryname=['Allemagne', 'Arabie Saoudite', 'Arabie Saoudite', 'Arabie Saoudite', 'Indonésie', 'Pakistan', 'Inde', 'Mozambique', 'Royaume-Uni', 'Turquie', 'Chine', 'Arabie Saoudite']
arrival_airport_list=['ERF', 'TUU', 'ELQ', 'GIZ', 'BTH', 'MUX', 'ULH', 'VXC', 'LBA', 'AOE', 'PKX', 'EAM']
arrival_airport_set = set(arrival_airport_list)
# Remplacement des valeurs NaN en utilisant une boucle
for index, row in df.iterrows():
    if row['arrival_airport'] in arrival_airport_set:
        idx = arrival_airport_list.index(row['arrival_airport'])
        df.at[index, 'arrival_cityname'] = cityname[idx]
        df.at[index, 'arrival_countryname'] = countryname[idx]
print(df.isna().sum())
#verification de la redondonce des lignes 
print(df.duplicated().sum())
duplicates = df[df.duplicated(subset=df.columns, keep=False)]#création d'un able qui contient que les lignes redondants
print(duplicates[['departure_airport','actual_departure_local','arrival_airport' ]]) # on va garder les lignes dont il ya des valeurs qui sont les mémes parceque chaque ligne correspond à un vol unique
#verification des colonnes qui ont des valeurs ' '(vide)
empty_columns = df.columns[df.eq('').any()]
empty_counts = df.eq('').sum()
print(empty_columns)
print(empty_counts)
print(df.shape)
#on va supprimer les colonnes suivantes vu qu'elles représentes beaucoup de valeurs ' ' (éviter la degradation de performance)
df=df.drop(columns=['departure_terminal','arrival_terminal'])
print(df.shape)
#création de deux colonnes (departure_delay,arrival_delay(cibe))
df['actual_departure_local']=pd.to_datetime(df['actual_departure_local'])
df['actual_arrival_local']=pd.to_datetime(df['actual_arrival_local'])
df['scheduled_departure_local']=pd.to_datetime(df['scheduled_departure_local'])
df['scheduled_arrival_local']=pd.to_datetime(df['scheduled_arrival_local'])
print(df.dtypes)
df['departure_delay']=df['actual_departure_local']-df['scheduled_departure_local']
df['arrival_delay']=df['actual_arrival_local']-df['scheduled_arrival_local']
df['departure_delay'] = df['departure_delay'].dt.total_seconds() / 60
df['arrival_delay']=df['arrival_delay'].dt.total_seconds() / 60
df['arrival_delay'].fillna(0, inplace=True)
df['departure_delay'].fillna(0, inplace=True)
df['arrival_delay']=df['arrival_delay'].astype('int')
df['departure_delay']=df['departure_delay'].astype('int')
columns_to_drop = ['actual_departure_local', 'actual_arrival_local', 'scheduled_departure_local', 'scheduled_arrival_local']
df = df.drop(columns=columns_to_drop)

"""division des données et traitement(encodage)"""

#x_train,x_test,y_train,y_test
X=df.drop('arrival_delay',axis=1)
y=df['arrival_delay']
print(y.unique())
X_train,X_test,y_train,y_test=train_test_split(X,y,test_size=0.2,random_state=42)
#Encodage des colonnes catégorielles 
h_encoder=OneHotEncoder(drop='first', sparse=False,handle_unknown='ignore')
cat=['departure_airport','flight_status_departure','arrival_airport' ,'flight_status_arrival' ,'airline_id','departure_countryname','departure_cityname','arrival_countryname','arrival_cityname' ]
X_train_encoded = h_encoder.fit_transform(X_train[cat])
X_test_encoded = h_encoder.transform(X_test[cat])

# Convertir les résultats en DataFrames avec les noms de colonnes générés par OneHotEncoder
X_train_encoded_df = pd.DataFrame(X_train_encoded, columns=h_encoder.get_feature_names_out(cat))
X_test_encoded_df = pd.DataFrame(X_test_encoded, columns=h_encoder.get_feature_names_out(cat))

# Réinitialiser les index pour pouvoir concaténer
X_train_encoded_df.index = X_train.index
X_test_encoded_df.index = X_test.index

# Supprimer les colonnes catégorielles d'origine des DataFrames d'origine
X_train.drop(columns=cat, inplace=True)
X_test.drop(columns=cat, inplace=True)

# Concaténer les DataFrames d'origine avec les nouvelles colonnes encodées
X_train = pd.concat([X_train, X_train_encoded_df], axis=1)
X_test = pd.concat([X_test, X_test_encoded_df], axis=1)
"""rfe methode pour selectionner les features les plus importants"""
# Choix de l'estimateur pour la RFE 
estimator = RandomForestRegressor()

# Créer l'objet RFE avec RandomForestRegressor comme estimateur
rfe = RFE(estimator, n_features_to_select=100)  

# Adapter la RFE aux données d'entraînement
rfe.fit(X_train, y_train)

# Afficher les features sélectionnées
selected_features = X_train.columns[rfe.support_]
print("Features sélectionnées par RFE :")
print(selected_features)
X_train_selected = rfe.transform(X_train)
X_test_selected = rfe.transform(X_test)

"""entrainement des modéles de regressions"""

models = {
    'Linear Regression': LinearRegression(),
    'Decision Tree': DecisionTreeRegressor(),
    'Random Forest': RandomForestRegressor(),
    'SVM': SVR()
}
for name, model in models.items():
    model.fit(X_train_selected , y_train)
"""test de différents modéles et identification de modéle champion"""

def compare_models(models, X_test_selected, y_test):
    results = {}
    
    # Calculer les métriques pour chaque modèle
    for name, model in models.items():
        y_pred = model.predict(X_test_selected)
        rmse = mean_squared_error(y_test, y_pred, squared=False)  
        mse = mean_squared_error(y_test, y_pred)  
        mae = mean_absolute_error(y_test, y_pred)  
        r2 = r2_score(y_test, y_pred)  
        
        results[name] = {'RMSE': rmse, 'MSE': mse, 'MAE': mae, 'R-squared': r2}
    
    # Comparer les performances des modèles
    best_model = None
    best_metrics = None
    for model_name, metrics in results.items():
        if best_model is None:
            best_model = model_name
            best_metrics = metrics
        else:
            # Compare les performances du modèle actuel avec le meilleur modèle actuel
            current_metrics = results[model_name]
            better = False
            for metric in ['RMSE', 'MSE', 'MAE', 'R-squared']:
                if metric == 'RMSE' or metric == 'MSE' or metric == 'MAE':
                    if current_metrics[metric] < best_metrics[metric]:
                        better = True
                        break
                elif metric == 'R-squared':
                    if current_metrics[metric] > best_metrics[metric]:
                        better = True
                        break
            if better:
                best_model = model_name
                best_metrics = current_metrics

    return best_model, best_metrics, results
best_model, best_metrics, all_results = compare_models(models, X_test_selected, y_test)
print("Meilleur modèle :", best_model)
print("Meilleures métriques :", best_metrics)
print("\nTous les résultats :")
print(pd.DataFrame(all_results))




