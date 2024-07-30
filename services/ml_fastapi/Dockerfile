# Utiliser une image de base légère de Python
FROM python:3.9-slim

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers de l'application
COPY . /app

RUN pip install --upgrade pip

# Installer les dépendances de l'application
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Installer MLflow et les dépendances supplémentaires si nécessaire
RUN pip install mlflow psycopg2-binary

# Exposer le port utilisé par l'application
EXPOSE 9544

# Commande pour lancer l'application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "9544"]
