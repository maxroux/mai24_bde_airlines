from dash import dcc, html
from data_loader import load_airports_data, load_flight_data, load_country_options, load_flight_status_options, load_departure_city_options

airports_data = load_airports_data()
real_flights_data = load_flight_data()
country_options = load_country_options(airports_data)
flight_status_options = load_flight_status_options(real_flights_data)
departure_city_options = load_departure_city_options(real_flights_data)

layout = html.Div([
    html.H1("Projet Airline", style={'text-align':'center'}),
    dcc.Tabs(id='tabs', value='tab-5', children=[
        dcc.Tab(label='Estimateur de retard des vols', value='tab-5'),
        dcc.Tab(label='Statistiques', value='tab-4'),
        dcc.Tab(label='Aéroports du monde', value='tab-2'),
        dcc.Tab(label='Vols terminés', value='tab-3'),
        dcc.Tab(label='Aéroports par pays', value='tab-1'),
    ]),
    html.Div(id='tabs-content')
], style={
    'width': '70%',
    'margin': '0 auto',
    'padding': '20px',
    'box-shadow': '0 4px 8px rgba(0,0,0,0.1)',
    'background-color': '#fff',
    'border-radius': '8px'
})
