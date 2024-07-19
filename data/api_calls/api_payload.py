import requests

def get_access_token():
    token_url = "https://api.lufthansa.com/v1/oauth/token"
    payload = {
        'client_id': "vss6aqb3gf2czn5syafmbrzp3",
        'client_secret': "VzZCePAxmQ",
        'grant_type': 'client_credentials'
    }
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded'
    }
    response = requests.post(token_url, data=payload, headers=headers)
    if response.status_code == 200:
        token_info = response.json()
        return token_info['access_token']
    else:
        print(f"Error: {response.status_code}")
        print(response.json())
        return None

if __name__ == "__main__":
    access_token = get_access_token()
    if access_token:
        print(f"Access Token: {access_token}")
