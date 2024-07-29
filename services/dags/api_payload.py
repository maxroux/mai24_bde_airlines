from airflow.hooks.base import BaseHook
import requests
import random

def get_access_token():
    # Liste des connexions configurées dans Airflow
    connections = [
        "lufthansa_api_1",
        "lufthansa_api_2",
        "lufthansa_api_3",
        "lufthansa_api_4"
    ]
    
    # Choisir une connexion aléatoire
    connection_id = random.choice(connections)
    connection = BaseHook.get_connection(connection_id)
    
    # Préparer le payload avec les informations de connexion
    payload = {
        'client_id': connection.login,
        'client_secret': connection.password,
        'grant_type': 'client_credentials'
    }
    
    headers_token = {
        'Content-Type': 'application/x-www-form-urlencoded'
    }
    
    # Obtenir l'URL du jeton à partir du host de la connexion
    url_token = f"https://{connection.host}/v1/oauth/token"
    
    # Envoyer la requête pour obtenir le token d'accès
    response_token = requests.post(url_token, headers=headers_token, data=payload)
    response_token.raise_for_status()
    
    # Extraire le token de la réponse
    token_info = response_token.json()
    return token_info['access_token']

if __name__ == "__main__":
    access_token = get_access_token()
    if access_token:
        print(f"Access Token: {access_token}")