#INIT
# pip install requests pandas
import requests
import json
import pandas as pd
# Définissez vos identifiants de l'API Lufthansa
CLIENT_ID = 'dg2ap3tn62qr5d85g6xxnbksw'
CLIENT_SECRET = 'cXPQbNPpWw'
AUTH_URL = 'https://api.lufthansa.com/v1/oauth/token'


# Obtenez un jeton d'accès
def get_access_token(client_id, client_secret):
    response = requests.post(AUTH_URL, data={
        'client_id': client_id,
        'client_secret': client_secret,
        'grant_type': 'client_credentials'
    })
    response_data = response.json()
    return response_data['access_token']

# Récupérez les données de référence depuis l'API
def get_reference_data(access_token, endpoint):
    url = f'https://api.lufthansa.com/v1/mds-references/{endpoint}'
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Accept': 'application/json'
    }
    response = requests.get(url, headers=headers)
    return response.json()

# Sauvegardez les données dans un fichier CSV
def save_to_csv(data, filename):
    df = pd.DataFrame(data)
    df.to_csv(filename, index=False)

# Sauvegardez les données dans un fichier JSON
def save_to_json(data, filename):
    with open(filename, 'w') as f:
        json.dump(data, f, indent=4)



# Points de terminaison pour les données de référence
reference_endpoints = [
    'countries',
    'cities',
    'airports',
    'airlines',
    'aircraft',
    # 'freight-classes'
]

def main():
    # Obtenez un jeton d'accès
    access_token = get_access_token(CLIENT_ID, CLIENT_SECRET)

    # Pour chaque point de terminaison, récupérez les données et sauvegardez-les dans un fichier CSV
    for endpoint in reference_endpoints:
        data = get_reference_data(access_token, endpoint)
        filename = f'{endpoint}.json'
        save_to_json(data, filename)
        print(f'Données sauvegardées dans {filename}')
        # save_to_csv(data, f'{endpoint}.csv')
        # print(f'Données sauvegardées dans {endpoint}.csv')

if __name__ == '__main__':
    main()
