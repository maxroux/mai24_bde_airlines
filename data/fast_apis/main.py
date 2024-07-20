from fastapi import FastAPI, HTTPException
from motor.motor_asyncio import AsyncIOMotorClient
from bson import ObjectId
import os
import logging

# Environment variables setup
MONGO_URI = os.getenv('MONGO_URI', 'mongodb://airline:airline@mongodb:27017/')
DATABASE_NAME = os.getenv('DATABASE_NAME', 'airline_project')

# MongoDB connection setup
client = AsyncIOMotorClient(MONGO_URI)
db = client[DATABASE_NAME]

# FastAPI app initialization
app = FastAPI()

# Configure logging
logging.basicConfig(level=logging.INFO)

def convert_object_ids(records):
    """Convert ObjectId to string in multiple records."""
    return [{**record, "_id": str(record["_id"])} if "_id" in record and isinstance(record["_id"], ObjectId) else record for record in records]

async def fetch_records(collection_name, query, limit, offset):
    """Fetch records from the MongoDB collection based on the query."""
    collection = db[collection_name]
    logging.info(f"MongoDB query on {collection_name}: {query}")
    try:
        records = await collection.find(query).skip(offset).limit(limit).to_list(length=limit)
        logging.info(f"Fetched {len(records)} records from {collection_name}")
        if not records:
            logging.info("No records found")
            raise HTTPException(status_code=404, detail="No records found")
        return convert_object_ids(records)
    except Exception as e:
        logging.error(f"Error fetching records from {collection_name}: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error")

async def fetch_record(collection_name, query):
    """Fetch a single record from the MongoDB collection based on the query."""
    collection = db[collection_name]
    logging.info(f"MongoDB query on {collection_name}: {query}")
    try:
        record = await collection.find_one(query)
        if not record:
            logging.info("No record found")
            raise HTTPException(status_code=404, detail="No record found")
        return convert_object_ids([record])[0]
    except Exception as e:
        logging.error(f"Error fetching record from {collection_name}: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error")

@app.get("/")
async def get_all_routes():
    routes = [
        {"method": "GET", "endpoint": "/countries"},
        {"method": "GET", "endpoint": "/countries/{country_code}"},
        {"method": "GET", "endpoint": "/aircrafts"},
        {"method": "GET", "endpoint": "/aircrafts/{aircraft_code}"},
        {"method": "GET", "endpoint": "/airlines"},
        {"method": "GET", "endpoint": "/airlines/{airline_id}"},
        {"method": "GET", "endpoint": "/airports"},
        {"method": "GET", "endpoint": "/airports/{airport_code}"},
        {"method": "GET", "endpoint": "/cities"},
        {"method": "GET", "endpoint": "/cities/{city_code}"},
        {"method": "GET", "endpoint": "/flights/airport/{airport_code}"},
        {"method": "GET", "endpoint": "/flights"},
        {"method": "GET", "endpoint": "/flights/{limit}/{offset}"},
        {"method": "GET", "endpoint": "/flights/airport/{airport_code}/{limit}/{offset}"},
        {"method": "GET", "endpoint": "/flights/airport/{airport_code}/schedule/{scheduled_time_utc}/{limit}/{offset}"},
        {"method": "GET", "endpoint": "/flights/route/{departure_airport_code}/{arrival_airport_code}"},
        {"method": "GET", "endpoint": "/flights/route/{departure_airport_code}/{arrival_airport_code}/{limit}/{offset}"}
    ]
    return {"available_routes": routes}

@app.get("/countries")
async def get_countries(limit: int = 100, offset: int = 0):
    logging.info("Fetching all countries")
    query = {}
    return await fetch_records('countries', query, limit, offset)

@app.get("/countries/{country_code}")
async def get_country_by_code(country_code: str):
    logging.info(f"Fetching country with code {country_code}")
    query = {"country_code": country_code}
    return await fetch_record('countries', query)

@app.get("/aircrafts")
async def get_aircrafts(limit: int = 100, offset: int = 0):
    logging.info("Fetching all aircrafts")
    query = {}
    return await fetch_records('aircrafts', query, limit, offset)

@app.get("/aircrafts/{aircraft_code}")
async def get_aircraft_by_code(aircraft_code: str):
    logging.info(f"Fetching aircraft with code {aircraft_code}")
    query = {"aircraft_code": aircraft_code}
    return await fetch_record('aircrafts', query)

@app.get("/airlines")
async def get_airlines(limit: int = 100, offset: int = 0):
    logging.info("Fetching all airlines")
    query = {}
    return await fetch_records('airlines', query, limit, offset)

@app.get("/airlines/{airline_id}")
async def get_airline_by_id(airline_id: str):
    logging.info(f"Fetching airline with ID {airline_id}")
    query = {"airline_id": airline_id}
    return await fetch_record('airlines', query)

@app.get("/airports")
async def get_airports(limit: int = 100, offset: int = 0):
    logging.info("Fetching all airports")
    query = {}
    return await fetch_records('airports', query, limit, offset)

@app.get("/airports/{airport_code}")
async def get_airport_by_code(airport_code: str):
    logging.info(f"Fetching airport with code {airport_code}")
    query = {"airport_code": airport_code}
    return await fetch_record('airports', query)

@app.get("/cities")
async def get_cities(limit: int = 100, offset: int = 0):
    logging.info("Fetching all cities")
    query = {}
    return await fetch_records('cities', query, limit, offset)

@app.get("/cities/{city_code}")
async def get_city_by_code(city_code: str):
    logging.info(f"Fetching city with code {city_code}")
    query = {"city_code": city_code}
    return await fetch_record('cities', query)

@app.get("/flights/airport/{airport_code}")
async def get_flights_from_airport(airport_code: str, limit: int = 100, offset: int = 0):
    logging.info(f"Fetching flights from airport {airport_code} with limit {limit} and offset {offset}")
    query = {"airport_code": airport_code}
    return await fetch_records('departures', query, limit, offset)

@app.get("/flights")
async def get_all_flights(limit: int = 100, offset: int = 0):
    logging.info(f"Fetching all flights with limit {limit} and offset {offset}")
    query = {}
    return await fetch_records('departures', query, limit, offset)

@app.get("/flights/{limit}/{offset}")
async def get_all_flights_with_pagination(limit: int = 100, offset: int = 0):
    logging.info(f"Fetching all flights with limit {limit} and offset {offset}")
    query = {}
    return await fetch_records('departures', query, limit, offset)

@app.get("/flights/airport/{airport_code}/{limit}/{offset}")
async def get_flights_by_airport(airport_code: str, limit: int = 100, offset: int = 0):
    logging.info(f"Fetching flights from airport {airport_code} with limit {limit} and offset {offset}")
    query = {"airport_code": airport_code}
    return await fetch_records('departures', query, limit, offset)

@app.get("/flights/airport/{airport_code}/schedule/{scheduled_time_utc}/{limit}/{offset}")
async def get_flights_by_schedule(airport_code: str, scheduled_time_utc: str, limit: int = 100, offset: int = 0):
    logging.info(f"Fetching flights from airport {airport_code} at {scheduled_time_utc} with limit {limit} and offset {offset}")
    query = {
        "airport_code": airport_code,
        "ScheduledTimeUTC": scheduled_time_utc
    }
    return await fetch_records('departures', query, limit, offset)

@app.get("/flights/route/{departure_airport_code}/{arrival_airport_code}")
@app.get("/flights/route/{departure_airport_code}/{arrival_airport_code}/{limit}/{offset}")
async def get_flights_by_route(departure_airport_code: str, arrival_airport_code: str, limit: int = 100, offset: int = 0):
    logging.info(f"Fetching flights from {departure_airport_code} to {arrival_airport_code} with limit {limit} and offset {offset}")
    query = {
        "airport_code": departure_airport_code,
        "data.FlightStatusResource.Flights.Flight.Arrival.AirportCode": arrival_airport_code
    }
    return await fetch_records('departures', query, limit, offset)
