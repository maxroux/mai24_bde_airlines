import dash
from dash import dcc, html
from dash.dependencies import Input, Output
import plotly.express as px
import plotly.graph_objs as go
import pandas as pd

# On charge les données des aéroports
file_path = '../data/airports.csv'
airports_data = pd.read_csv(file_path)

# On filtre les aéroports avec latitude ou longitude de 0
filtered_airports_data = airports_data[(airports_data['Latitude'] != 0) & (airports_data['Longitude'] != 0)]

# On charge les données des villes
cities_file_path = '../data/cities.csv'
cities_data = pd.read_csv(cities_file_path)

# On charge les données de vol à partir du fichier CSV fourni
flight_data_path = '../data/departure_result_with_all_coordinates.csv'
real_flights_data = pd.read_csv(flight_data_path)

# On affiche les colonnes des données de vol pour le debugging
print("Colonnes des données des vols:", real_flights_data.columns)

# On initialise l'application dash
app = dash.Dash(__name__, suppress_callback_exceptions=True)

# On obtient des codes pays uniques pour le dropdown
country_options = [{'label': country, 'value': country} for country in sorted(airports_data['CountryCode'].dropna().unique())]

# On obtient des options de statut de vol pour le dropdown
flight_status_options = [{'label': status, 'value': status} for status in real_flights_data['DepartureTimeStatus'].unique()]

# On définit le layout de l'application dash
app.layout = html.Div([
    html.H1("visualisation des données d'aéroports et de villes"),
    
    # On définit les onglets pour différentes visualisations
    dcc.Tabs(id='tabs', value='tab-1', children=[
        dcc.Tab(label='aperçu des aéroports', value='tab-1'),
        dcc.Tab(label='visualisation sur la carte', value='tab-2'),
        dcc.Tab(label='vols', value='tab-3'),# Nouvel onglet pour les vols
        dcc.Tab(label='statistiques', value='tab-4')  # Nouvel onglet pour les statistiques

    ]),
    
    html.Div(id='tabs-content')
])

# On définit le callback pour rendre le contenu de chaque onglet
@app.callback(Output('tabs-content', 'children'),
              Input('tabs', 'value'))
def render_content(tab):
    if tab == 'tab-1':
        return html.Div([
            # On affiche le dropdown pour sélectionner le pays
            dcc.Dropdown(
                id='country-dropdown',
                options=country_options,
                value='US',  # valeur par défaut
                clearable=False
            ),
            
            # On affiche la carte pour afficher les emplacements des aéroports
            dcc.Graph(id='map-graph', style={'height': '80vh'})
        ])
    elif tab == 'tab-2':
        return html.Div([
            # On affiche un slider pour sélectionner le nombre d'aéroports à afficher
            dcc.Slider(
                id='num-airports-slider',
                min=10,
                max=5000,
                step=10,
                value=100,  # valeur par défaut
                marks={i: str(i) for i in range(0, 5001, 500)}
            ),
            
            dcc.Graph(id='full-map-graph', style={'height': '100vh'})
        ])
    elif tab == 'tab-3':
        return html.Div([
            # On affiche le dropdown pour filtrer par statut de vol
            dcc.Dropdown(
                id='flight-status-dropdown',
                options=flight_status_options,
                value='On Time',  # valeur par défaut
                clearable=False
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


# On définit le callback pour mettre à jour les graphes dans l'onglet aperçu des aéroports
@app.callback(
    Output('map-graph', 'figure'),
    [Input('country-dropdown', 'value')]
)
def update_overview_graphs(selected_country):
    filtered_data = airports_data[airports_data['CountryCode'] == selected_country]
    
    # On crée la figure de la carte avec zoom automatique
    map_fig = px.scatter_geo(filtered_data,
                             lon='Longitude',
                             lat='Latitude',
                             hover_name='Name',
                             title=f'aéroports en {selected_country}',
                             projection="natural earth")
    map_fig.update_geos(fitbounds="locations")  # On fait le zoom automatique sur les points
    
    return map_fig

# On définit le callback pour mettre à jour la carte dans l'onglet visualisation sur la carte
@app.callback(
    Output('full-map-graph', 'figure'),
    [Input('num-airports-slider', 'value')]
)
def update_full_map(num_airports):
    # On crée la figure de la carte pour le nombre spécifié d'aéroports
    full_map_fig = px.scatter_geo(filtered_airports_data.head(num_airports),
                                  lon='Longitude',
                                  lat='Latitude',
                                  hover_name='Name',
                                  title=f'top {num_airports} aéroports',
                                  projection="natural earth")
    return full_map_fig

# On définit le callback pour mettre à jour la carte des vols
@app.callback(
    Output('real-flights-map', 'figure'),
    [Input('flight-status-dropdown', 'value')]
)
def update_real_flights_map(selected_status):
    filtered_flights_data = real_flights_data[real_flights_data['DepartureTimeStatus'] == selected_status]

    # On crée la figure de la carte
    fig = go.Figure()

    # On ajoute des points de départ
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

    # On ajoute des points d'arrivée
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

    # On dessine des lignes entre les points de départ et d'arrivée avec des informations de survol
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

    # On met à jour la disposition de la figure pour une vue GPS
    fig.update_layout(
        title='Départs et Arrivées des Vols',
        geo=dict(
            showland=True,
            showcountries=True,
        ),
        geo_scope='world',
        showlegend=False
    )
    return fig

@app.callback(
    [Output('flight-status-pie-chart', 'figure'),
     Output('top-flights-on-time', 'figure'),
     Output('top-flights-delayed', 'figure'),
     Output('top-airports', 'figure')],
    [Input('tabs', 'value')]
)
def update_statistics_visualizations(tab):
    if tab == 'tab-4':
        # Diagramme camembert pour les statuts des vols
        status_counts = real_flights_data['DepartureTimeStatus'].value_counts()
        pie_chart = px.pie(
            values=status_counts.values,
            names=status_counts.index,
            title='Part des vols en retard, annulé, à l\'heure'
        )

        # Top des vols à l'heure par pair ville de départ et ville d'arrivée
        on_time_flights = real_flights_data[real_flights_data['DepartureTimeStatus'] == 'Flight On Time']
        top_on_time_routes = on_time_flights.groupby(['DepartureAirportCode', 'ArrivalAirportCode']).size().reset_index(name='count').sort_values(by='count', ascending=False).head(10)
        top_on_time_routes['route'] = top_on_time_routes.apply(lambda row: f"{row['DepartureAirportCode']} -> {row['ArrivalAirportCode']}", axis=1)
        top_on_time_chart = px.bar(
            top_on_time_routes,
            x='count',
            y='route',
            orientation='h',
            title='Top 10 vols à l\'heure (par pair ville de départ, ville d\'arrivée)'
        )

        # Top des vols en retard par pair ville de départ et ville d'arrivée
        delayed_flights = real_flights_data[real_flights_data['DepartureTimeStatus'] == 'Flight Delayed']
        top_delayed_routes = delayed_flights.groupby(['DepartureAirportCode', 'ArrivalAirportCode']).size().reset_index(name='count').sort_values(by='count', ascending=False).head(10)
        top_delayed_routes['route'] = top_delayed_routes.apply(lambda row: f"{row['DepartureAirportCode']} -> {row['ArrivalAirportCode']}", axis=1)
        top_delayed_chart = px.bar(
            top_delayed_routes,
            x='count',
            y='route',
            orientation='h',
            title='Top 10 vols en retard (par pair ville de départ, ville d\'arrivée)'
        )

        # Top aéroports (arrivée ou départ)
        top_airports_series = pd.concat([real_flights_data['DepartureAirportCode'], real_flights_data['ArrivalAirportCode']])
        top_airports = top_airports_series.value_counts().reset_index(name='count').head(10)
        top_airports.columns = ['AirportCode', 'count']
        top_airports_chart = px.bar(
            top_airports,
            x='count',
            y='AirportCode',
            orientation='h',
            title='Top 10 aéroports (arrivée ou départ)'
        )

        return pie_chart, top_on_time_chart, top_delayed_chart, top_airports_chart
    return {}, {}, {}, {}




# Lancer l'application
if __name__ == '__main__':
    app.run_server(debug=True)
