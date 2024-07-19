from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import psycopg2
from typing import List

# Configuration de la connexion à la base de données
DATABASE = {
    'dbname': 'airline_project',
    'user': 'airline',
    'password': 'airline',
    'host': 'postgres',
    'port': '5432'
}

# Initialisation de l'application FastAPI
app = FastAPI()

# Modèle Pydantic pour les données des pays
class Country(BaseModel):
    CountryCode: str
    Names: str

# Fonction pour obtenir la connexion à la base de données
def get_db_connection():
    conn = psycopg2.connect(
        dbname=DATABASE['dbname'],
        user=DATABASE['user'],
        password=DATABASE['password'],
        host=DATABASE['host'],
        port=DATABASE['port']
    )
    return conn

# Route pour obtenir toutes les données des pays
@app.get("/countries", response_model=List[Country])
def get_countries():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT CountryCode, Names FROM countries")
    rows = cursor.fetchall()
    countries = []
    for row in rows:
        countries.append(Country(CountryCode=row[0], Names=row[1]))
    conn.close()
    return countries

# Route pour obtenir les données d'un pays spécifique par code
@app.get("/countries/{country_code}", response_model=Country)
def get_country(country_code: str):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT CountryCode, Names FROM countries WHERE CountryCode = %s", (country_code,))
    row = cursor.fetchone()
    conn.close()
    if row is None:
        raise HTTPException(status_code=404, detail="Country not found")
    return Country(CountryCode=row[0], Names=row[1])
