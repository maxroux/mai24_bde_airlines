from dash.dependencies import Input, Output, State
from datetime import datetime, timedelta
import plotly.express as px
import plotly.graph_objs as go
from data_loader import load_airports_data, load_flight_data, load_country_options, load_flight_status_options, load_departure_city_options, load_airlines_data, load_marketing_airline_ids_options
from dash import html, dcc
import pandas as pd
import logging
import requests

# Configurez le logger
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Date d'aujourd'hui
today = datetime.today().date()
# Date d'hier
yesterday = today - timedelta(days=1)

airlines_data = load_airlines_data()
airports_data = load_airports_data()
real_flights_data = load_flight_data()
country_options = load_country_options(airports_data)
flight_status_options = load_flight_status_options(real_flights_data)
departure_city_options = load_departure_city_options(airports_data)
marketing_airline_ids_options = load_marketing_airline_ids_options(airlines_data)

def register_callbacks(app):
    @app.callback(Output('tabs-content', 'children'),
                  Input('tabs', 'value'))
    def render_content(tab):
        if tab == 'tab-1':
            return html.Div([
                dcc.Dropdown(
                    id='country-dropdown',
                    options=country_options,
                    value='US',
                    clearable=False,
                    style={'margin':'10px 0 0 0','width':'100px'}
                ),
                dcc.Graph(id='map-graph', style={'height': '80vh'})
            ])
        elif tab == 'tab-2':
            return html.Div([
                dcc.Slider(
                    id='num-airports-slider',
                    min=100,
                    max=5000,
                    step=100,
                    value=1000,
                    marks={i: str(i) for i in range(0, 5001, 500)}
                ),
                dcc.Graph(id='full-map-graph', style={'height': '100vh'})
            ])
        elif tab == 'tab-3':
            return html.Div([
                dcc.Dropdown(
                    id='flight-status-dropdown',
                    options=flight_status_options,
                    value='Flight Delayed',
                    clearable=False,
                    style={'margin':'10px 0 0 0','width':'200px'}
                ),
                dcc.Loading(
                    id="loading",
                    type="default",
                    children=dcc.Graph(id='real-flights-map', style={'height': '100vh'})
                )
            ])
        elif tab == 'tab-4':
            return html.Div([
                dcc.Graph(id='flight-status-pie-chart'),
                dcc.Graph(id='top-flights-on-time'),
                dcc.Graph(id='top-flights-delayed'),
                dcc.Graph(id='top-airports')
            ])
        elif tab == 'tab-5':
            return html.Div([
                # Conteneur pour la sélection des villes
                html.Div([
                    html.Div([
                        html.Label('Aéroport de départ'),
                        dcc.Dropdown(
                            id='departure-city-dropdown',
                            options=departure_city_options,
                            placeholder="Ville de départ",
                            clearable=False,
                            value="FRA",
                            style={'width': '200px'}
                        ),
                    ], style={'padding': '10px'}),
                    html.Div([
                        html.Label('Aéroport d\'arrivée'),
                        dcc.Dropdown(
                            id='arrival-city-dropdown',
                            placeholder="Ville d'arrivée",
                            options=departure_city_options,
                            clearable=False,
                            value="JFK",
                            style={'width': '200px'}
                        ),
                    ], style={'padding': '10px'}),
                ], style={'display': 'flex', 'justify-content': 'space-between'}),

                # Conteneur pour la date et l'heure de départ
                html.Div([
                    html.Div([
                        html.Label('Date de départ'),
                        dcc.DatePickerSingle(
                            id='departure-date-picker',
                            placeholder="Date de départ",
                            style={'width': '150px'},
                            date=yesterday
                        ),
                    ], style={'padding': '10px'}),
                    html.Div([
                        html.Label('Heure de départ'),
                        dcc.Dropdown(
                            id='departure-hour-dropdown',
                            options=[{'label': str(i).zfill(2), 'value': str(i).zfill(2)} for i in range(24)],
                            placeholder="Heure",
                            value="00",
                            style={'width': '80px'}
                        ),
                    ], style={'padding': '10px'}),
                    html.Div([
                        html.Label('Minutes de départ'),
                        dcc.Dropdown(
                            id='departure-minute-dropdown',
                            options=[{'label': str(i).zfill(2), 'value': str(i).zfill(2)} for i in range(60)],
                            placeholder="Minutes",
                            value="00",
                            style={'width': '80px'}
                        ),
                    ], style={'padding': '10px'}),
                ], style={'display': 'flex', 'justify-content': 'space-between'}),

                # Ligne pour le délai au départ
                html.Div([
                    html.Label('délai au départ (min)'),
                    dcc.Input(
                        id='departure-delay-input',
                        type='number',
                        placeholder="délai au départ (min)",
                        value=0,
                        style={'margin-right':'10px'}
                    ),
                    html.Label('Marketing id'),
                    dcc.Dropdown(
                        id='airline-marketing-id-dropdown',
                        options=marketing_airline_ids_options,
                        placeholder="Marketing id",
                        clearable=False,
                        value="KE"
                    ),
                ], style={'padding': '10px', 'display': 'flex', 'justify-content': 'space-between'}),

                # Conteneur pour la date et l'heure d'arrivée
                html.Div([
                    html.Div([
                        html.Label('Date d\'arrivée'),
                        dcc.DatePickerSingle(
                            id='arrival-date-picker',
                            placeholder="Date d'arrivée",
                            style={'width': '150px'},
                            date=yesterday,
                        ),
                    ], style={'padding': '10px'}),
                    html.Div([
                        html.Label('Heure d\'arrivée'),
                        dcc.Dropdown(
                            id='arrival-hour-dropdown',
                            options=[{'label': str(i).zfill(2), 'value': str(i).zfill(2)} for i in range(24)],
                            placeholder="Heure",
                            value="00",
                            style={'width': '80px'}
                        ),
                    ], style={'padding': '10px'}),
                    html.Div([
                        html.Label('Minutes d\'arrivée'),
                        dcc.Dropdown(
                            id='arrival-minute-dropdown',
                            options=[{'label': str(i).zfill(2), 'value': str(i).zfill(2)} for i in range(60)],
                            placeholder="Minutes",
                            value="00",
                            style={'width': '80px'}
                        ),
                    ], style={'padding': '10px'}),
                ], style={'display': 'flex', 'justify-content': 'space-between'}),
                
                # Dans la définition de votre layout, utilisez dcc.Loading pour le output
                html.Div([
                    html.Button('Prédire le retard', id='predict-button', style={'marginTop': '20px', 'width': '200px', 'padding': '10px'}),
                    dcc.Loading(
                        id="loading-output",
                        type="default",
                        children=html.Div(id='delay-output', style={'marginTop': '20px', 'fontSize': '20px', 'fontWeight': 'bold', 'text-align': 'center', 'width': '100%'})
                    )
                ], style={'text-align': 'center'}),
                
                # Output du retard avec un loader
                dcc.Loading(
                    id="loading-output",
                    type="default",
                    children=html.Div(id='delay-output', style={'marginTop': '20px', 'fontSize': '40px', 'fontWeight': 'bold', 'text-align': 'center', 'width': '100%'})
                )
                ], style={'max-width': '600px', 'margin': 'auto'})

    @app.callback(
        Output('map-graph', 'figure'),
        [Input('country-dropdown', 'value')]
    )
    def update_overview_graphs(selected_country):
        filtered_data = airports_data[airports_data['CountryCode'] == selected_country]
        map_fig = px.scatter_geo(filtered_data,
                                 lon='Longitude',
                                 lat='Latitude',
                                 #hover_name='Name',
                                 projection="natural earth")
        map_fig.update_geos(fitbounds="locations")
        return map_fig

    @app.callback(
        Output('full-map-graph', 'figure'),
        [Input('num-airports-slider', 'value')]
    )
    def update_full_map(num_airports):
        filtered_airports_data = airports_data[(airports_data['Latitude'] != 0) & (airports_data['Longitude'] != 0)]
        full_map_fig = px.scatter_geo(filtered_airports_data.head(num_airports),
                                      lon='Longitude',
                                      lat='Latitude',
                                  #    hover_name='Name',
                                      projection="natural earth")
        return full_map_fig

    @app.callback(
        Output('real-flights-map', 'figure'),
        [Input('flight-status-dropdown', 'value')]
    )
    def update_real_flights_map(selected_status):
        filtered_flights_data = real_flights_data[real_flights_data['DepartureTimeStatus'] == selected_status]
        fig = go.Figure()
        fig.add_trace(go.Scattergeo(
            lon=filtered_flights_data['DepartureLongitude'],
            lat=filtered_flights_data['DepartureLatitude'],
            mode='markers',
            marker=dict(
                size=8,
                symbol='square',
                color='blue'
            ),
            name='Départ',
            hoverinfo='text',
            hovertext=filtered_flights_data.apply(
                lambda row: f"Départ: {row['DepartureAirportCode']}, Programmé: {row['ScheduledDepartureLocal']}, Réel: {row['ActualDepartureLocal']}",
                axis=1
            )
        ))
        fig.add_trace(go.Scattergeo(
            lon=filtered_flights_data['ArrivalLongitude'],
            lat=filtered_flights_data['ArrivalLatitude'],
            mode='markers',
            marker=dict(
                size=8,
                symbol='circle',
                color='red'
            ),
            name='Arrivée',
            hoverinfo='text',
            hovertext=filtered_flights_data.apply(
                lambda row: f"Arrivée: {row['ArrivalAirportCode']}, Programmé: {row['ScheduledArrivalLocal']}, Réel: {row['ActualArrivalLocal']}",
                axis=1
            )
        ))
        flight_status_colors = {
            'On Time': 'green',
            'Delayed': 'orange',
            'Cancelled': 'red'
        }
        for idx, row in filtered_flights_data.iterrows():
            fig.add_trace(go.Scattergeo(
                lon=[row['DepartureLongitude'], row['ArrivalLongitude']],
                lat=[row['DepartureLatitude'], row['ArrivalLatitude']],
                mode='lines',
                line=dict(width=1, color=flight_status_colors.get(row['DepartureTimeStatus'], 'gray')),
                opacity=0.6,
                hoverinfo='text',
                hovertext=f"Vol {row['MarketingFlightNumber']}: {row['DepartureTimeStatus']}",
                name=f"Vol {row['MarketingFlightNumber']}"
            ))
        fig.update_layout(
            geo=dict(
                showland=True,
                showcountries=True,
            ),
            geo_scope='world',
            showlegend=False
        )
        return fig
    
    flights_data = load_flight_data()

    @app.callback(
    [Output('flight-status-pie-chart', 'figure'),
     Output('top-flights-on-time', 'figure'),
     Output('top-flights-delayed', 'figure'),
     Output('top-airports', 'figure')],
    [Input('tabs', 'value')]
    )
    def update_statistics_visualizations(tab):
        if tab == 'tab-4':
            # Exemple de traitement des données et création des graphiques
            if flights_data.empty:
                return {}, {}, {}, {}

            # Graphique en camembert pour les statuts des vols
            status_counts = flights_data['DepartureTimeStatus'].value_counts()
            pie_chart = px.pie(
                values=status_counts.values,
                names=status_counts.index,
                title='Part des vols par statut'
            )

            # Top 10 des vols à l'heure
            
            on_time_flights = flights_data[flights_data['DepartureTimeStatus'] == 'Flight On Time']
            top_on_time_routes = on_time_flights.groupby(['DepartureAirportCode', 'ArrivalAirportCode']).size().reset_index(name='count').sort_values(by='count', ascending=False).head(10)
            top_on_time_routes['route'] = top_on_time_routes.apply(lambda row: f"{row['DepartureAirportCode']} -> {row['ArrivalAirportCode']}", axis=1)
            top_on_time_chart = px.bar(
                top_on_time_routes,
                x='count',
                y='route',
                orientation='h',
                title='Top 10 vols à l\'heure'
            )

            # Top 10 des vols en retard
            delayed_flights = flights_data[flights_data['DepartureTimeStatus'] == 'Flight Delayed']
            top_delayed_routes = delayed_flights.groupby(['DepartureAirportCode', 'ArrivalAirportCode']).size().reset_index(name='count').sort_values(by='count', ascending=False).head(10)
            top_delayed_routes['route'] = top_delayed_routes.apply(lambda row: f"{row['DepartureAirportCode']} -> {row['ArrivalAirportCode']}", axis=1)
            top_delayed_chart = px.bar(
                top_delayed_routes,
                x='count',
                y='route',
                orientation='h',
                title='Top 10 vols en retard'
            )

            # Top 10 des aéroports
            top_airports_series = pd.concat([flights_data['DepartureAirportCode'], flights_data['ArrivalAirportCode']])
            top_airports = top_airports_series.value_counts().reset_index(name='count').head(10)
            top_airports.columns = ['AirportCode', 'count']
            top_airports_chart = px.bar(
                top_airports,
                x='count',
                y='AirportCode',
                orientation='h',
                title='Top 10 aéroports'
            )

            return pie_chart, top_on_time_chart, top_delayed_chart, top_airports_chart

        return {}, {}, {}, {}

    # La callback pour la prédiction du retard
    @app.callback(
        [Output('delay-output', 'children'),
        Output('delay-output', 'style')],
        [Input('predict-button', 'n_clicks')],
        [State('departure-city-dropdown', 'value'),
        State('arrival-city-dropdown', 'value'),
        State('airline-marketing-id-dropdown', 'value'),
        State('departure-date-picker', 'date'),
        State('departure-hour-dropdown', 'value'),
        State('departure-minute-dropdown', 'value'),
        State('departure-delay-input', 'value'),
        State('arrival-date-picker', 'date'),
        State('arrival-hour-dropdown', 'value'),
        State('arrival-minute-dropdown', 'value')]
    )
    def estimate_flight_delay(n_clicks, departure_city, arrival_city, marketing_airline_id, departure_date, departure_hour, departure_minute, departure_delay, arrival_date, arrival_hour, arrival_minute):
        if not n_clicks:
            return "", {}

        if not (departure_city and arrival_city and departure_date and departure_hour and departure_minute and arrival_date and arrival_hour and arrival_minute and departure_delay is not None):
            return "Tous les champs sont obligatoires", {'color': 'black'}

        try:
            departure_datetime = datetime.strptime(f"{departure_date} {departure_hour}:{departure_minute}", "%Y-%m-%d %H:%M")
            arrival_datetime = datetime.strptime(f"{arrival_date} {arrival_hour}:{arrival_minute}", "%Y-%m-%d %H:%M")
        except ValueError as e:
            logger.error(f"Erreur lors de la construction des datetime: {e}")
            return "Erreur dans les formats de date ou d'heure", {'color': 'black'}

        # Vérification que la date et l'heure d'arrivée ne sont pas antérieures à celles de départ
        if arrival_datetime < departure_datetime:
            return "La date et l'heure d'arrivée doivent être postérieures à celles de départ", {'color': 'red'}

        if departure_delay > 0:
            departure_time_status_code = "DE"
        elif departure_delay < 0:
            departure_time_status_code = "FE"
        else:
            departure_time_status_code = "NO"

        # Construction des horaires au format UTC
        departure_datetime_utc = departure_datetime.strftime("%Y-%m-%dT%H:%M:%SZ")
        arrival_datetime_utc = arrival_datetime.strftime("%Y-%m-%dT%H:%M:%SZ")

        # Appel API pour prédire le retard
        url = "http://airlineproject.duckdns.org:8002/predict_delay"
        payload = {
            "departure_airport_code": departure_city,
            "arrival_airport_code": arrival_city,
            "departure_scheduled_time_utc": departure_datetime_utc,
            "arrival_scheduled_time_utc": arrival_datetime_utc,
            "marketing_airline_id": marketing_airline_id,
            "operating_airline_id": "",
            "aircraft_code": "",
            "departure_delay": departure_delay,
            "departure_time_status_code": departure_time_status_code,
        }

        logger.info(f"Payload envoyé : {payload}")

        try:
            response = requests.post(url, json=payload)
            response_data = response.json()
            logger.info(f"Réponse de l'API : {response_data}")
            delay = round(response_data.get("predicted_delay", [0])[0])  # Arrondir le délai
        except Exception as e:
            logger.error(f"Erreur lors de l'appel à l'API: {e}")
            delay = 0

        if delay == 0:
            return "Pas de retard", {'color': 'green'}
        else:
            return f"Délai estimé: {delay} minutes", {'color': 'red'}