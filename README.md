# URL utiles
- DASHBOARD disponible à l'adress suivant : http://airlineproject.duckdns.org:8050 TODO implémenter la prédiction avec un formulaire 
- API disponible à l'adresse : suivante : http://airlineproject.duckdns.org:8002/  DONE implémenter la prédiction dans la même api et non pas dans une API séparée comme actuellement
- MLFLOW: http://airlineproject.duckdns.org:5001/
- AIRFLOW : http://airlineproject.duckdns.org:8085/ (user et mdp : airline) 
- GRAFANA : http://airlineproject.duckdns.org:3001/ (user: admin, mdp: airline) => aller dans la rubrique Dashboards
- PROMETHEUS: http://airlineproject.duckdns.org:9090/ 

## Routes Disponibles

### GET `/countries`

- **Description**: Récupère tous les pays.
- **Paramètres**:
  - `limit` (optionnel, par défaut: 100) : Limite le nombre de résultats.
  - `offset` (optionnel, par défaut: 0) : Décale les résultats de la limite spécifiée.

### GET `/countries/{country_code}`

- **Description**: Récupère les informations sur un pays spécifique basé sur le code du pays.
- **Paramètres**:
  - `country_code` : Le code du pays.

### GET `/aircrafts`

- **Description**: Récupère tous les aéronefs.
- **Paramètres**:
  - `limit` (optionnel, par défaut: 100) : Limite le nombre de résultats.
  - `offset` (optionnel, par défaut: 0) : Décale les résultats de la limite spécifiée.

### GET `/aircrafts/{aircraft_code}`

- **Description**: Récupère les informations sur un aéronef spécifique basé sur le code de l'aéronef.
- **Paramètres**:
  - `aircraft_code` : Le code de l'aéronef.

### GET `/airlines`

- **Description**: Récupère toutes les compagnies aériennes.
- **Paramètres**:
  - `limit` (optionnel, par défaut: 100) : Limite le nombre de résultats.
  - `offset` (optionnel, par défaut: 0) : Décale les résultats de la limite spécifiée.

### GET `/airlines/{airline_id}`

- **Description**: Récupère les informations sur une compagnie aérienne spécifique basée sur l'ID de la compagnie.
- **Paramètres**:
  - `airline_id` : L'ID de la compagnie aérienne.

### GET `/airports`

- **Description**: Récupère tous les aéroports.
- **Paramètres**:
  - `limit` (optionnel, par défaut: 100) : Limite le nombre de résultats.
  - `offset` (optionnel, par défaut: 0) : Décale les résultats de la limite spécifiée.

### GET `/airports/{airport_code}`

- **Description**: Récupère les informations sur un aéroport spécifique basé sur le code de l'aéroport.
- **Paramètres**:
  - `airport_code` : Le code de l'aéroport.

### GET `/cities`

- **Description**: Récupère toutes les villes.
- **Paramètres**:
  - `limit` (optionnel, par défaut: 100) : Limite le nombre de résultats.
  - `offset` (optionnel, par défaut: 0) : Décale les résultats de la limite spécifiée.

### GET `/cities/{city_code}`

- **Description**: Récupère les informations sur une ville spécifique basée sur le code de la ville.
- **Paramètres**:
  - `city_code` : Le code de la ville.

### GET `/flights/airport/{airport_code}`

- **Description**: Récupère les vols depuis un aéroport spécifique.
- **Paramètres**:
  - `airport_code` : Le code de l'aéroport.
  - `limit` (optionnel, par défaut: 100) : Limite le nombre de résultats.
  - `offset` (optionnel, par défaut: 0) : Décale les résultats de la limite spécifiée.

### GET `/flights`

- **Description**: Récupère tous les vols.
- **Paramètres**:
  - `limit` (optionnel, par défaut: 100) : Limite le nombre de résultats.
  - `offset` (optionnel, par défaut: 0) : Décale les résultats de la limite spécifiée.

### GET `/flights/{limit}/{offset}`

- **Description**: Récupère tous les vols avec pagination.
- **Paramètres**:
  - `limit` (optionnel, par défaut: 100) : Limite le nombre de résultats.
  - `offset` (optionnel, par défaut: 0) : Décale les résultats de la limite spécifiée.

### GET `/flights/airport/{airport_code}/{limit}/{offset}`

- **Description**: Récupère les vols depuis un aéroport spécifique avec pagination.
- **Paramètres**:
  - `airport_code` : Le code de l'aéroport.
  - `limit` (optionnel, par défaut: 100) : Limite le nombre de résultats.
  - `offset` (optionnel, par défaut: 0) : Décale les résultats de la limite spécifiée.

### GET `/flights/airport/{airport_code}/schedule/{scheduled_time_utc}/{limit}/{offset}`

- **Description**: Récupère les vols depuis un aéroport spécifique à une heure programmée avec pagination.
- **Paramètres**:
  - `airport_code` : Le code de l'aéroport.
  - `scheduled_time_utc` : L'heure programmée en UTC.
  - `limit` (optionnel, par défaut: 100) : Limite le nombre de résultats.
  - `offset` (optionnel, par défaut: 0) : Décale les résultats de la limite spécifiée.

### GET `/flights/route/{departure_airport_code}/{arrival_airport_code}`

- **Description**: Récupère les vols entre deux aéroports spécifiques.
- **Paramètres**:
  - `departure_airport_code` : Le code de l'aéroport de départ.
  - `arrival_airport_code` : Le code de l'aéroport d'arrivée.
  - `limit` (optionnel, par défaut: 100) : Limite le nombre de résultats.
  - `offset` (optionnel, par défaut: 0) : Décale les résultats de la limite spécifiée.

### GET `/flights/route/{departure_airport_code}/{arrival_airport_code}/{limit}/{offset}`

- **Description**: Récupère les vols entre deux aéroports spécifiques avec pagination.
- **Paramètres**:
  - `departure_airport_code` : Le code de l'aéroport de départ.
  - `arrival_airport_code` : Le code de l'aéroport d'arrivée.
  - `limit` (optionnel, par défaut: 100) : Limite le nombre de résultats.
  - `offset` (optionnel, par défaut: 0) : Décale les résultats de la limite spécifiée.

### POST `/predict_delay`

- **Description**: Prédit le retard de vol entre deux aéroports spécifiques.
- **Paramètres**:
  - `departure_airport_code`: Code de l'aéroport de départ (ex: "JFK").
  - `arrival_airport_code`: Code de l'aéroport d'arrivée (ex: "LAX").
  - `departure_scheduled_time_utc`: Heure de départ prévue en UTC (ex: "2023-07-30T14:00:00Z").
  - `arrival_scheduled_time_utc`: Heure d'arrivée prévue en UTC (ex: "2023-07-30T17:00:00Z").
  - `marketing_airline_id`: ID de la compagnie aérienne commerciale (ex: "AA").
  - `operating_airline_id`: ID de la compagnie aérienne opérant le vol (ex: "AA").
  - `aircraft_code`: Code de l'aéronef (ex: "32B").

## Routes de Schéma

### GET `/schema/flights`

- **Description**: Récupère la structure des données des vols.
- **Réponse**:
  - `departure_airport` : Code de l'aéroport de départ
  - `scheduled_departure_local` : Heure de départ prévue (heure locale)
  - `actual_departure_local` : Heure de départ réelle (heure locale)
  - `departure_terminal` : Terminal de départ
  - `flight_status_departure` : Statut du vol au départ
  - `arrival_airport` : Code de l'aéroport d'arrivée
  - `scheduled_arrival_local` : Heure d'arrivée prévue (heure locale)
  - `actual_arrival_local` : Heure d'arrivée réelle (heure locale)
  - `arrival_terminal` : Terminal d'arrivée
  - `flight_status_arrival` : Statut du vol à l'arrivée
  - `airline_id` : ID de la compagnie aérienne

### GET `/schema/countries`

- **Description**: Récupère la structure des données des pays.
- **Réponse**:
  - `country_code` : Code du pays
  - `country_name` : Nom du pays

### GET `/schema/airports`

- **Description**: Récupère la structure des données des aéroports.
- **Réponse**:
  - `airport_code` : Code de l'aéroport
  - `city_name` : Nom de la ville
  - `country_name` : Nom du pays

### GET `/schema/cities`

- **Description**: Récupère la structure des données des villes.
- **Réponse**:
  - `city_code` : Code de la ville
  - `city_name` : Nom de la ville
  - `country_name` : Nom du pays

### GET `/schema/airlines`

- **Description**: Récupère la structure des données des compagnies aériennes.
- **Réponse**:
  - `airline_id` : ID de la compagnie aérienne
  - `airline_name` : Nom de la compagnie aérienne

### GET `/schema/aircrafts`

- **Description**: Récupère la structure des données des aéronefs.
- **Réponse**:
  - `aircraft_code` : Code de l'aéronef
  - `aircraft_name` : Nom de l'aéronef
