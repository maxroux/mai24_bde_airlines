from dash import dcc, html
from data_loader import load_airports_data, load_flight_data, load_country_options, load_flight_status_options, load_departure_city_options

airports_data = load_airports_data()
real_flights_data = load_flight_data()
country_options = load_country_options(airports_data)
flight_status_options = load_flight_status_options(real_flights_data)
departure_city_options = load_departure_city_options(real_flights_data)

layout = html.Div([
    html.H1("Visualisation des données d'aéroports et de villes"),
    dcc.Tabs(id='tabs', value='tab-1', children=[
        dcc.Tab(label='Aperçu des aéroports', value='tab-1'),
        dcc.Tab(label='Visualisation sur la carte', value='tab-2'),
        dcc.Tab(label='Vols', value='tab-3'),
        dcc.Tab(label='Statistiques', value='tab-4'),
        dcc.Tab(label='Estimateur de retard', value='tab-5')
    ]),
    html.Div(id='tabs-content')
])
