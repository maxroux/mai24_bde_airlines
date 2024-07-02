import dash
from dash import dcc, html
from dash.dependencies import Input, Output
import plotly.express as px
import pandas as pd

# charger les données
file_path = '../data/airports.csv'
airports_data = pd.read_csv(file_path)

# filtrer les aéroports avec latitude ou longitude de 0
filtered_airports_data = airports_data[(airports_data['Latitude'] != 0) & (airports_data['Longitude'] != 0)]

# charger les données des villes
cities_file_path = '../data/cities.csv'
cities_data = pd.read_csv(cities_file_path)

# imprimer les colonnes des données des villes pour le debugging
print("Colonnes des données des villes:", cities_data.columns)

# initialiser l'application dash
app = dash.Dash(__name__, suppress_callback_exceptions=True)

# obtenir des codes pays uniques pour le dropdown
country_options = [{'label': country, 'value': country} for country in sorted(airports_data['CountryCode'].dropna().unique())]

# options pour le nombre d'aéroports
num_airports_options = [{'label': str(i), 'value': i} for i in [10, 50, 100, 500, 1000, 5000]]

# layout de l'application dash
app.layout = html.Div([
    html.H1("visualisation des données d'aéroports et de villes"),
    
    # onglets pour differentes visualisations
    dcc.Tabs(id='tabs', value='tab-1', children=[
        dcc.Tab(label='aperçu des aéroports', value='tab-1'),
        dcc.Tab(label='visualisation sur la carte', value='tab-2'),
        dcc.Tab(label='données des villes', value='tab-3')
    ]),
    
    html.Div(id='tabs-content')
])

# callback pour rendre le contenu de chaque onglet
@app.callback(Output('tabs-content', 'children'),
              Input('tabs', 'value'))
def render_content(tab):
    if tab == 'tab-1':
        return html.Div([
            # dropdown pour sélectionner le pays
            dcc.Dropdown(
                id='country-dropdown',
                options=country_options,
                value='US',  # valeur par défaut
                clearable=False
            ),
            
            # carte pour afficher les emplacements des aéroports
            dcc.Graph(id='map-graph', style={'height': '80vh'})
        ])
    elif tab == 'tab-2':
        return html.Div([
            # dropdown pour sélectionner le nombre d'aéroports à afficher
            dcc.Dropdown(
                id='num-airports-dropdown',
                options=num_airports_options,
                value=100,  # valeur par défaut
                clearable=False
            ),
            
            dcc.Graph(id='full-map-graph', style={'height': '100vh'})
        ])
    elif tab == 'tab-3':
        return html.Div([
            # visualisation des données des villes
            dcc.Graph(id='city-map'),
            dcc.Graph(id='city-code-distribution'),
            dcc.Graph(id='country-code-distribution')
        ])

# callback pour mettre à jour les graphes dans l'onglet aperçu des aéroports
@app.callback(
    Output('map-graph', 'figure'),
    [Input('country-dropdown', 'value')]
)
def update_overview_graphs(selected_country):
    filtered_data = airports_data[airports_data['CountryCode'] == selected_country]
    
    # figure de la carte avec zoom automatique
    map_fig = px.scatter_geo(filtered_data,
                             lon='Longitude',
                             lat='Latitude',
                             hover_name='Name',
                             title=f'aéroports en {selected_country}',
                             projection="natural earth")
    map_fig.update_geos(fitbounds="locations")  # zoom automatique sur les points
    
    return map_fig

# callback pour mettre à jour la carte dans l'onglet visualisation sur la carte
@app.callback(
    Output('full-map-graph', 'figure'),
    [Input('num-airports-dropdown', 'value')]
)
def update_full_map(num_airports):
    # figure de la carte pour le nombre spécifié d'aéroports
    full_map_fig = px.scatter_geo(filtered_airports_data.head(num_airports),
                                  lon='Longitude',
                                  lat='Latitude',
                                  hover_name='Name',
                                  title=f'top {num_airports} aéroports',
                                  projection="natural earth")
    return full_map_fig

# callback pour mettre à jour les visualisations des villes
@app.callback(
    [Output('city-map', 'figure'),
     Output('city-code-distribution', 'figure'),
     Output('country-code-distribution', 'figure')],
    [Input('tabs', 'value')]
)
def update_city_visualizations(tab):
    if tab == 'tab-3':
        # figure de la carte des villes
        city_map_fig = px.scatter_geo(cities_data,
                                      lon='Longitude',
                                      lat='Latitude',
                                      hover_name='Name',
                                      title='emplacements des villes',
                                      projection="natural earth")
        
        # distribution des city codes
        city_code_dist_fig = px.histogram(cities_data,
                                          x='CityCode',
                                          title='distribution des city codes')
        
        # distribution des country codes
        country_code_dist_fig = px.histogram(cities_data,
                                             x='CountryCode',
                                             title='distribution des country codes')
        
        return city_map_fig, city_code_dist_fig, country_code_dist_fig
    return {}, {}, {}

# lancer l'application
if __name__ == '__main__':
    app.run_server(debug=True)
