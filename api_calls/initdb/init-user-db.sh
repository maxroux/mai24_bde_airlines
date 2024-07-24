#!/bin/bash
set -e

echo "Starting database initialization..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER airline WITH PASSWORD 'airline';
    CREATE DATABASE IF NOT EXISTS airline_project;
    GRANT ALL PRIVILEGES ON DATABASE airline_project TO airline;
    CREATE DATABASE IF NOT EXISTS airline_project_airflow;
    GRANT ALL PRIVILEGES ON DATABASE airline_project TO airline;
EOSQL

echo "Database initialization completed."
