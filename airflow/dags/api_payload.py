import requests
import random

def get_access_token():
    url_token = "https://api.lufthansa.com/v1/oauth/token"
    payload = list()
    payload.append({
        'client_id': "vss6aqb3gf2czn5syafmbrzp3",
        'client_secret': "VzZCePAxmQ",
        'grant_type': 'client_credentials'
    })
    payload.append({
        'client_id': "v47w6dvsccvpx8j46ymvbtzkn",
        'client_secret': "yqgD6EzQmb",
        'grant_type': 'client_credentials'
    })
    payload.append({
        'client_id': "m7eccvja28j882ndzn4h46fuh",
        'client_secret': "nu228RpY9M",
        'grant_type': 'client_credentials'
    })
    headers_token = {
        'Content-Type': 'application/x-www-form-urlencoded'
    }
    
    pay = payload[random.randint(0,len(payload)-1)]
    print(pay)
    response_token = requests.post(url_token, headers=headers_token, data=pay)
    response_token.raise_for_status()
    token_info = response_token.json()
    return token_info['access_token']

if __name__ == "__main__":
    access_token = get_access_token()
    if access_token:
        print(f"Access Token: {access_token}")
