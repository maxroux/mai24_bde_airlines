# Utiliser une image Python officielle comme image de base
FROM python:3.9-slim

# Définir le répertoire de travail
WORKDIR /app

# Copier le fichier de dépendances et installer les dépendances
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copier le reste de l'application
COPY . .

# Définir la commande par défaut pour exécuter le script
CMD ["python", "feed_to_mongodb.py"]
