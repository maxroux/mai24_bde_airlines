import pandas as pd

def load_airports_data():
    file_path = '/app/data/airports.csv'
    return pd.read_csv(file_path)

def load_flight_data():
    flight_data_path = '/app/data/departure_result_with_all_coordinates.csv'
    return pd.read_csv(flight_data_path)

def load_country_options(airports_data):
    return [{'label': country, 'value': country} for country in sorted(airports_data['CountryCode'].dropna().unique())]

def load_flight_status_options(flights_data):
    return [{'label': status, 'value': status} for status in flights_data['DepartureTimeStatus'].unique()]

def load_departure_city_options(flights_data):
    return [{'label': city, 'value': city} for city in sorted(flights_data['DepartureAirportCode'].unique())]
