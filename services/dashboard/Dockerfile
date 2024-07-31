# Utiliser une image Python officielle comme base
FROM python:3.9-slim

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers de dépendances dans le conteneur
COPY requirements.txt .

# Installer les dépendances
RUN pip install --no-cache-dir -r requirements.txt

# Copier uniquement le nécessaire dans le conteneur
COPY ./app ./app

# Créer un utilisateur non-root et définir les permissions
RUN useradd -m appuser && chown -R appuser /app
USER appuser

# Exposer le port de l'application
EXPOSE 8050

# Lancer l'application
CMD ["python", "app/app.py"]
