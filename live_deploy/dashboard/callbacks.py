from dash.dependencies import Input, Output
import plotly.express as px
import plotly.graph_objs as go
import random
from data_loader import load_airports_data, load_flight_data, load_country_options, load_flight_status_options, load_departure_city_options
from dash import html, dcc
import pandas as pd
import plotly.figure_factory as ff
from sklearn.metrics import confusion_matrix
import numpy as np

airports_data = load_airports_data()
real_flights_data = load_flight_data()
country_options = load_country_options(airports_data)
flight_status_options = load_flight_status_options(real_flights_data)
departure_city_options = load_departure_city_options(real_flights_data)

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
                    clearable=False
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
        elif tab == 'tab-5':
            return html.Div([
                dcc.Dropdown(
                    id='departure-city-dropdown',
                    options=departure_city_options,
                    placeholder="Ville de départ",
                    clearable=False,
                    value="ADA",
                    style={'marginBottom': '20px'}
                ),
                dcc.Dropdown(
                    id='arrival-city-dropdown',
                    placeholder="Ville d'arrivée",
                    clearable=False,
                    style={'marginBottom': '20px'}
                ),
                html.Div(id='delay-output', style={'marginTop': '20px', 'fontSize': '20px', 'fontWeight': 'bold'}),
                dcc.Graph(id='confusion-matrix', style={'marginTop': '20px'}),
                dcc.Graph(id='delay-comparison', style={'marginTop': '20px'})
            ])

    @app.callback(
        Output('map-graph', 'figure'),
        [Input('country-dropdown', 'value')]
    )
    def update_overview_graphs(selected_country):
        filtered_data = airports_data[airports_data['CountryCode'] == selected_country]
        map_fig = px.scatter_geo(filtered_data,
                                 lon='Longitude',
                                 lat='Latitude',
                                 hover_name='Name',
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
                                      hover_name='Name',
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
            status_counts = real_flights_data['DepartureTimeStatus'].value_counts()
            pie_chart = px.pie(
                values=status_counts.values,
                names=status_counts.index,
                title='Part des vols en retard, annulé, à l\'heure'
            )

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

    @app.callback(
        [Output('arrival-city-dropdown', 'options'),
         Output('arrival-city-dropdown', 'value')],
        [Input('departure-city-dropdown', 'value')]
    )
    def update_arrival_city_options(selected_departure):
        filtered_data = real_flights_data[real_flights_data['DepartureAirportCode'] == selected_departure]
        arrival_city_options = [{'label': city, 'value': city} for city in sorted(filtered_data['ArrivalAirportCode'].unique())]
        return arrival_city_options, arrival_city_options[0]['value'] if arrival_city_options else None

    @app.callback(
        [Output('delay-output', 'children'),
        Output('delay-output', 'style'),
        Output('confusion-matrix', 'figure'),
        Output('delay-comparison', 'figure')],
        [Input('departure-city-dropdown', 'value'),
        Input('arrival-city-dropdown', 'value')]
    )
    def estimate_flight_delay(departure_city, arrival_city):
        if not departure_city or not arrival_city:
            return "Sélectionnez une ville de départ et d'arrivée", {'color': 'black'}, {}, {}

        delay = random.choice([0, random.randint(1, 120)])  # Random delay for demonstration

        # Generate random data for confusion matrix and comparison chart
        y_true = np.random.choice([0, 1], size=100)  # Actual delays: 0 (no delay), 1 (delay)
        y_pred = np.random.choice([0, 1], size=100)  # Predicted delays
        cm = confusion_matrix(y_true, y_pred)

        z = cm[::-1]  # flip matrix for visualization
        x = ['No Delay', 'Delay']
        y = ['Delay', 'No Delay']

        fig_cm = ff.create_annotated_heatmap(z, x=x, y=y, colorscale='Viridis')
        fig_cm.update_layout(title='Matrice de confusion', margin=dict(t=50, l=50))

        fig_delay_comparison = go.Figure()
        fig_delay_comparison.add_trace(go.Bar(x=['Retard prédit', 'Retard réel'], y=[np.mean(y_pred), np.mean(y_true)]))
        fig_delay_comparison.update_layout(title='Retard prédit vs Retard réel', margin=dict(t=50, l=50))

        if delay == 0:
            return "Pas de retard", {'color': 'green'}, fig_cm, fig_delay_comparison
        else:
            return f"Délai estimé: {delay} minutes", {'color': 'red'}, fig_cm, fig_delay_comparison

