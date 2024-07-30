import os

# Informations de connexion à déclarer
api_connections = [
    {
        'conn_id': "lufthansa_api_1",
        'client_id': "vss6aqb3gf2czn5syafmbrzp3",
        'client_secret': "VzZCePAxmQ"
    },
    {
        'conn_id': "lufthansa_api_2",
        'client_id': "v47w6dvsccvpx8j46ymvbtzkn",
        'client_secret': "yqgD6EzQmb"
    },
    {
        'conn_id': "lufthansa_api_3",
        'client_id': "m7eccvja28j882ndzn4h46fuh",
        'client_secret': "nu228RpY9M"
    },
    {
        'conn_id': "lufthansa_api_4",
        'client_id': "m7eccvja28j882ndzn4h46fuh",
        'client_secret': "nu228RpY9M"
    }
]

# URL de l'API 
api_host = "api.lufthansa.com/v1/oauth/token"

# Script pour ajouter les connexions via le CLI Airflow
for conn in api_connections:
    conn_id = conn['conn_id']
    client_id = conn['client_id']
    client_secret = conn['client_secret']
    
    # Commande CLI pour ajouter une connexion
    command = f"airflow connections add '{conn_id}' --conn-type 'http' --conn-host '{api_host}' --conn-login '{client_id}' --conn-password '{client_secret}'"
    
    # Exécuter la commande (décommentez pour exécuter)
    os.system(command)
    
    # Afficher la commande pour vérification
    print(command)
