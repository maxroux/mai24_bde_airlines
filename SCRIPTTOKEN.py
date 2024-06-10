
import requests
token_url = "https://api.lufthansa.com/v1/oauth/token"
payload = {
    'client_id': 'v47w6dvsccvpx8j46ymvbtzkn',
    'client_secret': 'yqgD6EzQmb',
    'grant_type': 'client_credentials'
}
headers = {
    'Content-Type': 'application/x-www-form-urlencoded'
}
response = requests.post(token_url, data=payload, headers=headers)
if response.status_code == 200:
    token_info = response.json()
    access_token = token_info['access_token']
    print(f"Access Token: {access_token}")
else:
    print(f"Erreur: {response.status_code}")
    print(response.json())


