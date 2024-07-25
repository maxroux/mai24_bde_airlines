CREATE TABLE Countries (
    CountryCode VARCHAR(100) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    ZoneCode VARCHAR(100) NOT NULL
);

CREATE TABLE Cities (
    CityCode VARCHAR(100) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    CountryCode VARCHAR(100) NOT NULL,
    Longitude FLOAT,
    Latitude FLOAT
);

CREATE TABLE Airports (
    AirportCode VARCHAR(10) PRIMARY KEY,
    CityCode VARCHAR(10) NOT NULL,
    Name VARCHAR(100) NOT NULL,
    CountryCode VARCHAR(100) NOT NULL,
    LocationType VARCHAR(100),
    Longitude FLOAT,
    Latitude FLOAT
);

CREATE TABLE Airlines (
    AirlineID VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL
);

CREATE TABLE Aircrafts (
    Name VARCHAR(100) PRIMARY KEY
);
