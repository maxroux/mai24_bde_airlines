import json
import csv

# Function to read airport coordinates from the CSV file
def read_airport_coordinates(filepath):
    airport_coordinates = {}
    with open(filepath, 'r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            airport_code = row['AirportCode']
            latitude = row['Latitude']
            longitude = row['Longitude']
            airport_coordinates[airport_code] = (latitude, longitude)
    return airport_coordinates

# Read the airport coordinates
airport_coordinates = read_airport_coordinates('airports.csv')

# Read the JSON file
with open('departure_result.json', 'r') as file:
    data = json.load(file)

# Define all possible fields
all_fields = [
    'AirportCode', 'DepartureAirportCode', 'DepartureLatitude', 'DepartureLongitude', 
    'ScheduledDepartureLocal', 'ScheduledDepartureUTC', 'ActualDepartureLocal', 
    'ActualDepartureUTC', 'DepartureTimeStatus', 'ArrivalAirportCode', 
    'ArrivalLatitude', 'ArrivalLongitude', 'ScheduledArrivalLocal', 'ScheduledArrivalUTC', 
    'ActualArrivalLocal', 'ActualArrivalUTC', 'ArrivalTimeStatus', 'MarketingAirlineID', 
    'MarketingFlightNumber', 'OperatingAirlineID', 'OperatingFlightNumber', 'AircraftCode', 
    'AircraftRegistration', 'FlightStatus', 'ServiceType'
]

# Extract flight information and add coordinates
flights = []
for airport_data in data:
    airport_code = airport_data.get('airport_code')
    flight_data = airport_data.get('data', {}).get('FlightStatusResource', {}).get('Flights', {}).get('Flight', [])
    for flight in flight_data:
        departure_airport_code = flight.get('Departure', {}).get('AirportCode')
        arrival_airport_code = flight.get('Arrival', {}).get('AirportCode')
        flight_info = {
            'AirportCode': airport_code,
            'DepartureAirportCode': departure_airport_code,
            'DepartureLatitude': airport_coordinates.get(departure_airport_code, (None, None))[0],
            'DepartureLongitude': airport_coordinates.get(departure_airport_code, (None, None))[1],
            'ScheduledDepartureLocal': flight.get('Departure', {}).get('ScheduledTimeLocal', {}).get('DateTime'),
            'ScheduledDepartureUTC': flight.get('Departure', {}).get('ScheduledTimeUTC', {}).get('DateTime'),
            'ActualDepartureLocal': flight.get('Departure', {}).get('ActualTimeLocal', {}).get('DateTime'),
            'ActualDepartureUTC': flight.get('Departure', {}).get('ActualTimeUTC', {}).get('DateTime'),
            'DepartureTimeStatus': flight.get('Departure', {}).get('TimeStatus', {}).get('Definition'),
            'ArrivalAirportCode': arrival_airport_code,
            'ArrivalLatitude': airport_coordinates.get(arrival_airport_code, (None, None))[0],
            'ArrivalLongitude': airport_coordinates.get(arrival_airport_code, (None, None))[1],
            'ScheduledArrivalLocal': flight.get('Arrival', {}).get('ScheduledTimeLocal', {}).get('DateTime'),
            'ScheduledArrivalUTC': flight.get('Arrival', {}).get('ScheduledTimeUTC', {}).get('DateTime'),
            'ActualArrivalLocal': flight.get('Arrival', {}).get('ActualTimeLocal', {}).get('DateTime'),
            'ActualArrivalUTC': flight.get('Arrival', {}).get('ActualTimeUTC', {}).get('DateTime'),
            'ArrivalTimeStatus': flight.get('Arrival', {}).get('TimeStatus', {}).get('Definition'),
            'MarketingAirlineID': flight.get('MarketingCarrier', {}).get('AirlineID'),
            'MarketingFlightNumber': flight.get('MarketingCarrier', {}).get('FlightNumber'),
            'OperatingAirlineID': flight.get('OperatingCarrier', {}).get('AirlineID'),
            'OperatingFlightNumber': flight.get('OperatingCarrier', {}).get('FlightNumber'),
            'AircraftCode': flight.get('Equipment', {}).get('AircraftCode'),
            'AircraftRegistration': flight.get('Equipment', {}).get('AircraftRegistration'),
            'FlightStatus': flight.get('FlightStatus', {}).get('Definition'),
            'ServiceType': flight.get('ServiceType')
        }
        # Add missing fields as None
        for field in all_fields:
            if field not in flight_info:
                flight_info[field] = None
        flights.append(flight_info)

# Write the information to a new CSV file
with open('departure_result_with_all_coordinates.csv', 'w', newline='') as csvfile:
    writer = csv.DictWriter(csvfile, fieldnames=all_fields)
    writer.writeheader()
    for flight in flights:
        writer.writerow(flight)

print("Fichier CSV avec coordonnées créé avec succès.")
