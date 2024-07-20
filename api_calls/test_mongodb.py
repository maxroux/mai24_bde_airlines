from pymongo import MongoClient
from bson.objectid import ObjectId

# Configuration de la connexion à MongoDB
mongo_client = MongoClient('mongodb://localhost:27017/')
mongo_db = mongo_client['airline_project']
mongo_collection = mongo_db['departures']

# Fonction pour créer un document
def create_flight(airport_code, scheduled_time_utc, data):
    flight = {
        "airport_code": airport_code,
        "ScheduledTimeUTC": scheduled_time_utc,
        "data": data
    }
    result = mongo_collection.insert_one(flight)
    return result.inserted_id

# Fonction pour lire tous les documents avec limite et offset
def read_flights(limit=100, offset=0):
    flights = list(mongo_collection.find().skip(offset).limit(limit))
    return flights

# Fonction pour lire les documents par code d'aéroport avec limite et offset
def read_flights_by_airport(airport_code, limit=100, offset=0):
    flights = list(mongo_collection.find({"airport_code": airport_code}).skip(offset).limit(limit))
    return flights

# Fonction pour lire les documents par code d'aéroport et heure UTC programmée avec limite et offset
def read_flight_by_airport_and_time(airport_code, scheduled_time_utc, limit=100, offset=0):
    flights = list(mongo_collection.find({"airport_code": airport_code, "ScheduledTimeUTC": scheduled_time_utc}).skip(offset).limit(limit))
    return flights

# Fonction pour mettre à jour un document
def update_flight(flight_id, update_data):
    result = mongo_collection.update_one({"_id": ObjectId(flight_id)}, {"$set": update_data})
    return result.modified_count

# Fonction pour supprimer un document
def delete_flight(flight_id):
    result = mongo_collection.delete_one({"_id": ObjectId(flight_id)})
    return result.deleted_count

# Tester les fonctions
if __name__ == "__main__":
    # Créer un document
    flight_id = create_flight("CDG", "2024-07-20T00:00", {"status": "on-time"})
    print(f"Document créé avec l'ID : {flight_id}")

    # Lire tous les documents
    print("Tous les vols :")
    flights = read_flights(limit=2, offset=0)
    for flight in flights:
        print(flight)

    # Lire les documents par code d'aéroport
    print("Vols par code d'aéroport (CDG) :")
    flights = read_flights_by_airport("CDG", limit=2, offset=0)
    for flight in flights:
        print(flight)

    # Lire les documents par code d'aéroport et heure UTC programmée
    print("Vols par code d'aéroport (CDG) et heure UTC programmée :")
    flights = read_flight_by_airport_and_time("CDG", "2024-07-20T00:00", limit=2, offset=0)
    for flight in flights:
        print(flight)

    # Mettre à jour un document
    updated_count = update_flight(flight_id, {"data.status": "delayed"})
    print(f"Nombre de documents mis à jour : {updated_count}")

    # Supprimer un document
    deleted_count = delete_flight(flight_id)
    print(f"Nombre de documents supprimés : {deleted_count}")
