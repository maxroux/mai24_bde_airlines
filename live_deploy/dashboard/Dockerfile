# Utiliser une image Python officielle comme base
FROM python:3.9-slim

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers de dépendances dans le conteneur
COPY requirements.txt requirements.txt

# Installer les dépendances
RUN pip install --no-cache-dir -r requirements.txt

# Copier le reste des fichiers de l'application dans le conteneur
COPY . .

# Définir la variable d'environnement pour le port
ENV PORT 8050

# Exposer le port de l'application
EXPOSE $PORT

# Lancer l'application
CMD ["python", "app.py"]
