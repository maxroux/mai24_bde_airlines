import pandas as pd

def load_airports_data():
    file_path = '/app/data/airports.csv'
    try:
        df = pd.read_csv(file_path)
        print(f"Airports data loaded successfully with {df.shape[0]} records.")
        return df
    except Exception as e:
        print(f"Error loading airports data: {e}")
        return pd.DataFrame()

def load_flight_data():
    flight_data_path = '/app/data/departure_result_with_all_coordinates.csv'
    try:
        df = pd.read_csv(flight_data_path)
        print(f"Flight data loaded successfully with {df.shape[0]} records.")
        return df
    except Exception as e:
        print(f"Error loading flight data: {e}")
        return pd.DataFrame()
    
def load_airlines_data():
    file_path = '/app/data/unique_airline_ids.csv'
    try:
        df = pd.read_csv(file_path)
        print(f"Unique airline IDs data loaded successfully with {df.shape[0]} records.")
        return df
    except Exception as e:
        print(f"Error loading unique airline IDs data: {e}")
        return pd.DataFrame()
    
def load_country_options(airports_data):
    if airports_data.empty:
        print("No data available in airports_data.")
        return []
    return [{'label': country, 'value': country} for country in sorted(airports_data['CountryCode'].dropna().unique())]

def load_flight_status_options(flights_data):
    if flights_data.empty:
        print("No data available in flights_data.")
        return []
    return [{'label': status, 'value': status} for status in flights_data['DepartureTimeStatus'].unique()]

def load_departure_city_options(airports_data):
    if airports_data.empty:
        print("No data available in airports_data.")
        return []
    return [{'label': country, 'value': country} for country in sorted(airports_data['AirportCode'].dropna().unique())]

def load_operating_airline_ids_options(airlines_data):
    if airlines_data.empty:
        print("No data available in flight_data.")
        return []
    unique_operating_ids = airlines_data['OperatingAirlineID'].dropna().unique()
    print(f"Unique operating airline IDs: {len(unique_operating_ids)} found.")
    return [{'label': airline_id, 'value': airline_id} for airline_id in unique_operating_ids]

def load_marketing_airline_ids_options(airlines_data):
    if airlines_data.empty:
        print("No data available in flight_data.")
        return []
    unique_marketing_ids = airlines_data['MarketingAirlineID'].dropna().unique()
    print(f"Unique marketing airline IDs: {len(unique_marketing_ids)} found.")
    return [{'label': airline_id, 'value': airline_id} for airline_id in unique_marketing_ids]


