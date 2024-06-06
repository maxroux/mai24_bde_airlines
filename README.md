# mai24_bde_airlines
### Description détaillée :
De nos jours, il est possible d’avoir des informations sur les vols dans le monde entier et de traquer en temps réel un avion. Nous pouvons observer ce site en guise d’exemple. Le but ici est de s’y approcher le plus possible en passant par des API de différentes compagnies aériennes.

### Étapes

#### 1. Récolte des données
**Description :**
Passer par l’API de Lufthansa pour récupérer des données sur les vols. Vous pouvez tester les différentes routes de l’API de Lufthansa à l’aide de ce lien. Vous pourrez être amené à aller puiser différentes informations comme les codes IATA.

**Objectif :**
Comprendre les données que vous pouvez récupérer et faire un choix des routes à utiliser. Il y a aussi l’API de International Airlines, mais il se peut que vous ayez des soucis pour y accéder.

**Modules / Masterclass / Templates :**
- Utilisation de la librairie requests ou de l’outil Postman (pour tester)
- Techniques de webscraping

**Conditions de validation du projet :**
- Fichier explicatif du traitement et des différentes données accessibles (doc / pdf)
- Un exemple de données collectées

#### 2. Architecture des données
**Description :**
Lors de la précédente étape, nous avons observé qu’il y a plusieurs “types” de données. Nous allons qualifier des données de fixe comme les informations sur les aéroports et de variables, les informations sur les vols.

**Objectif :**
Cette diversification de données va conduire à une utilisation de différentes bases de données.

**Modules / Masterclass / Templates :**
- SQL
- Architecture des données
- Elasticsearch
- MongoDB
- Neo4j

**Conditions de validation du projet :**
- Une base de données relationnelle
- Diagramme UML
- Un fichier de requête SQL pour montrer que c’est bien fonctionnel
- Exemples de requêtes Elastic/Mongo

#### 3. Consommation de la donnée
**Description :**
Faire un algorithme de prédiction de retard des avions grâce aux données que vous avez précédemment stockées dans vos Bases de données. Mettre en place ML Flow pour pouvoir faire du versioning de Modèles.

**Modules / Masterclass / Templates :**
- DE120
- ML Flow

**Conditions de validation du projet :**
- Algorithme de Machine Learning
- ML Flow Fonctionnel

#### 4. Déploiement
**Description :**
Créer une API pour requêter ces différentes bases de données. Faire un conteneur Docker de chaque composant du projet (BDD, API) et faire un docker-compose fonctionnel. Mesurer la dérive des données.

**Modules / Masterclass / Templates :**
- FastAPI / Flask
- Docker
- Data Drift

**Conditions de validation du projet :**
- API FastAPI
- Conteneur, Fichier yaml du docker-compose

#### 5. Automatisation et Monitoring
**Description :**
Récupérer les données de l’API Lufthansa selon un rythme bien défini pour l’envoyer aux différents consommateurs de la donnée. Créer un pipeline simple de CI pour déployer des nouveautés. Monitorer l’application en production ainsi que les logs API.

**Modules / Masterclass / Templates :**
- Cronjob
- Airflow
- Prometheus Grafana

**Conditions de validation du projet :**
- Fichier python du DAG

#### 6. Soutenance
**Description :**
Démonstration de leur appli et explication du raisonnement effectué lors de leur projet.

**Objectif :**
X

**Modules / Masterclass / Templates :**
X

**Conditions de validation du projet :**
- Soutenance
- Rapport
