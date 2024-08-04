FROM apache/airflow:2.8.1

RUN pip install --upgrade pip

# On passe à l'utilisateur airflow pour installer les dépendances
USER airflow
COPY requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

# On repasse à l'utilisateur root pour installer des paquets supplémentaires et configurer les permissions
USER root
RUN apt-get update && apt-get install -y \
    libgomp1 && pip3 install --no-cache-dir mlflow==2.9.2

# On crée un répertoire pour les artefacts MLflow, on définit le propriétaire et les permissions
RUN mkdir -p /mlflow \
    && chown -R airflow:root /mlflow \
    && chmod -R 777 /mlflow

# On expose les ports
EXPOSE 5000

# On repasse à l'utilisateur airflow pour des raisons de sécurité
USER airflow