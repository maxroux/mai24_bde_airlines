import subprocess
from bson import ObjectId
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime, timedelta
import psycopg2
import smtplib
from email.mime.text import MIMEText
import os
import logging
from pymongo import MongoClient
import json
from airflow.hooks.base import BaseHook

# Configuration des arguments par défaut du DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Définition du DAG
dag = DAG(
    'daily_data_dumps',
    default_args=default_args,
    description='Un dump SQL et MongoDB quotidien',
    schedule_interval=timedelta(days=1),
    catchup=False, 
    tags=['backups']
)

def perform_sql_dump():
    try:
        postgres_conn = BaseHook.get_connection('api_calls_postgres')
        dump_file = f"/opt/airflow/data/dumps/postgres_dumps/airline_project_dump_{datetime.now().strftime('%Y%m%d')}.sql"
        os.makedirs(os.path.dirname(dump_file), exist_ok=True)
        
        pg_dump_command = [
            "pg_dump",
            f"--dbname=postgresql://{postgres_conn.login}:{postgres_conn.password}@{postgres_conn.host}:{postgres_conn.port}/{postgres_conn.schema}",
            "-F", "c",
            "-b",
            "-v",
            "-f", dump_file
        ]
        logging.info(f"Commande pg_dump: {' '.join(pg_dump_command)}")
        
        subprocess.run(pg_dump_command, check=True)
        logging.info(f"Dump SQL créé: {dump_file}")

        send_email_via_smtp("Dump SQL réussi", "Le dump SQL a été créé avec succès.")
    
    except subprocess.CalledProcessError as e:
        logging.error(f"Erreur lors de l'exécution de pg_dump: {e}")
        send_email_via_smtp("Échec du dump SQL", f"Échec de la création du dump SQL: {e}")
    except Exception as e:
        logging.error(f"Erreur lors de la création du dump SQL: {e}")
        send_email_via_smtp("Échec du dump SQL", f"Échec de la création du dump SQL: {e}")


def perform_mongodb_dump():
    try:
        mongo_conn = BaseHook.get_connection('api_calls_mongodb')
        # Construit l'URI de connexion à MongoDB
        uri = f"mongodb://{mongo_conn.login}:{mongo_conn.password}@{mongo_conn.host}:{mongo_conn.port}"
        client = MongoClient(uri)
        db = client['airline_project']
        
        collections = db.list_collection_names()
        
        for collection_name in collections:
            collection = db[collection_name]
            data = []
            for doc in collection.find():
                doc['_id'] = str(doc['_id'])
                data.append(doc)
            
            dump_file = f"/opt/airflow/data/dumps/mongodb_dumps/dump_{collection_name}_{datetime.now().strftime('%Y%m%d')}.json"
            os.makedirs(os.path.dirname(dump_file), exist_ok=True)
            
            with open(dump_file, 'w') as f:
                json.dump(data, f)
            
            logging.info(f"Dump de la collection {collection_name} créé : {dump_file}")
        
        send_email_via_smtp("Dump MongoDB réussi", "Les dumps MongoDB ont été créés avec succès.")
    
    except Exception as e:
        logging.error(f"Erreur lors de la création des dumps MongoDB : {e}")
        send_email_via_smtp("Échec des dumps MongoDB", f"Échec de la création des dumps MongoDB : {e}")

def send_email_via_smtp(subject, body):
    from_email = "mehdi.fekih@edhec.com"
    to_email = "telegram@mailrise.xyz"
    
    msg = MIMEText(body)
    msg["Subject"] = subject
    msg["From"] = from_email
    msg["To"] = to_email
    
    smtp_server = "192.168.10.168"
    smtp_port = 8025
    
    with smtplib.SMTP(smtp_server, smtp_port) as server:
        server.sendmail(from_email, [to_email], msg.as_string())
        logging.info("E-mail envoyé via Mailrise.")

# Définition des tâches du DAG
t1 = PythonOperator(
    task_id='perform_sql_dump',
    python_callable=perform_sql_dump,
    dag=dag,
)

t2 = PythonOperator(
    task_id='perform_mongodb_dump',
    python_callable=perform_mongodb_dump,
    dag=dag,
)

t1 >> t2
