import dash
from dash.dependencies import Input, Output
from layout import layout
from callbacks import register_callbacks

# On initialise l'application Dash
app = dash.Dash(__name__, suppress_callback_exceptions=True)
app.layout = layout

# On enregistre les callbacks
register_callbacks(app)

# On exécute l'application
if __name__ == '__main__':
    app.run_server(debug=True, host='0.0.0.0')
