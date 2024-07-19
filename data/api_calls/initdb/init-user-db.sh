#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE USER airline;
	CREATE DATABASE airline_project;
	GRANT ALL PRIVILEGES ON DATABASE airline TO airline_project;
EOSQL
