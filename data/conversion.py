import json
import csv

with open('departure_result.json', 'r') as file:
    data = json.load(file)

all_fields = [
    'AirportCode', 'DepartureAirportCode', 'ScheduledDepartureLocal', 'ScheduledDepartureUTC',
    'ActualDepartureLocal', 'ActualDepartureUTC', 'DepartureTimeStatus', 'ArrivalAirportCode',
    'ScheduledArrivalLocal', 'ScheduledArrivalUTC', 'ActualArrivalLocal', 'ActualArrivalUTC',
    'ArrivalTimeStatus', 'MarketingAirlineID', 'MarketingFlightNumber', 'OperatingAirlineID',
    'OperatingFlightNumber', 'AircraftCode', 'AircraftRegistration', 'FlightStatus', 'ServiceType'
]

flights = []
for airport_data in data:
    airport_code = airport_data.get('airport_code')
    flight_data = airport_data.get('data', {}).get('FlightStatusResource', {}).get('Flights', {}).get('Flight', [])
    for flight in flight_data:
        flight_info = {
            'AirportCode': airport_code,
            'DepartureAirportCode': flight.get('Departure', {}).get('AirportCode'),
            'ScheduledDepartureLocal': flight.get('Departure', {}).get('ScheduledTimeLocal', {}).get('DateTime'),
            'ScheduledDepartureUTC': flight.get('Departure', {}).get('ScheduledTimeUTC', {}).get('DateTime'),
            'ActualDepartureLocal': flight.get('Departure', {}).get('ActualTimeLocal', {}).get('DateTime'),
            'ActualDepartureUTC': flight.get('Departure', {}).get('ActualTimeUTC', {}).get('DateTime'),
            'DepartureTimeStatus': flight.get('Departure', {}).get('TimeStatus', {}).get('Definition'),
            'ArrivalAirportCode': flight.get('Arrival', {}).get('AirportCode'),
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
                for field in all_fields:
            if field not in flight_info:
                flight_info[field] = None
        flights.append(flight_info)

with open('departure_result.csv', 'w', newline='') as csvfile:
    writer = csv.DictWriter(csvfile, fieldnames=all_fields)

    writer.writeheader()
    for flight in flights:
        writer.writerow(flight)

print("Fichier CSV créé avec succès.")
