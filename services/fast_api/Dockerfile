# Utiliser une image Python officielle comme image parent
FROM python:3.9-slim

# Définir le répertoire de travail dans le conteneur
WORKDIR /app

# Copier le fichier requirements.txt dans le conteneur
COPY requirements.txt .

# Installer les dépendances système
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Mettre à jour pip
RUN pip install --upgrade pip

# Installer les dépendances Python
RUN pip install --no-cache-dir -r requirements.txt

# Créer un répertoire pour les artefacts temporaires
RUN mkdir /app/temp_artifacts

# Copier le reste du code de l'application dans le conteneur
COPY . .

# Exposer le port 8000 pour l'application
EXPOSE 8000

# Lancer l'application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
