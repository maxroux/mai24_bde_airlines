#!/bin/sh

# Attendre que le fichier de verrouillage soit créé
echo "Waiting for the model to be registered..."
while [ ! -f /tmp/model_registered.lock ]; do
  sleep 1
done

echo "Model registered. Starting the API..."
# Démarrer l'application FastAPI
exec uvicorn main:app --host 0.0.0.0 --port 8000

