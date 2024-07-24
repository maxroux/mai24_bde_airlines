FROM python:3.8

WORKDIR /app

# Copier les fichiers du répertoire courant dans le conteneur
COPY . /app

# Installer les dépendances
RUN pip install -r requirements.txt

# Définir la commande par défaut
CMD ["python", "main.py"]

