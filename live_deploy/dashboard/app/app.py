import dash
from dash.dependencies import Input, Output
from live_deploy.dashboard.app.layout import layout
from callbacks import register_callbacks

# Initialize the Dash app
app = dash.Dash(__name__, suppress_callback_exceptions=True)
app.layout = layout

# Register the callbacks
register_callbacks(app)

# Run the application
if __name__ == '__main__':
    app.run_server(debug=True)
