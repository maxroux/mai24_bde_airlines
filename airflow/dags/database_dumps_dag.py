from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime, timedelta
import psycopg2
import smtplib
from email.mime.text import MIMEText
import os
import logging

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
    'daily_sql_dump',
    default_args=default_args,
    description='Un dump SQL quotidien',
    schedule_interval=timedelta(days=1),
    catchup=False,  # Pas de rattrapage
)

def perform_sql_dump():
    conn = None
    try:
        # Connexion à la base de données PostgreSQL
        conn = psycopg2.connect(
            dbname="airline_project",
            user="airline",
            password="airline",
            host="api_calls_postgres",
            port="5432"
        )
        logging.info("Connexion à la base de données réussie.")

        # Vérification des tables présentes dans la base de données
        cur = conn.cursor()
        cur.execute("SELECT table_name FROM information_schema.tables WHERE table_schema='public';")
        tables = cur.fetchall()
        logging.info(f"Tables présentes dans la base de données: {tables}")

        # Création d'un dump SQL
        dump_file = f"/opt/airflow/data/dumps/airline_project_dump_{datetime.now().strftime('%Y%m%d')}.sql"
        pg_dump_command = f"PGPASSWORD='airline' pg_dump -U airline -h api_calls_postgres -d airline_project > {dump_file}"
        logging.info(f"Commande pg_dump: {pg_dump_command}")
        
        dump_result = os.system(pg_dump_command)
        if dump_result != 0:
            logging.error(f"Échec de la commande pg_dump avec le code de sortie: {dump_result}")
            raise Exception("La commande pg_dump a échoué")
        else:
            logging.info(f"Dump SQL créé: {dump_file}")

        # Envoi de la notification par e-mail via Mailrise
        send_email_via_smtp("Dump SQL réussi", "Le dump SQL a été créé avec succès.")
        logging.info("Notification de succès envoyée.")
    
    except Exception as e:
        # En cas d'erreur, envoi de la notification par e-mail via Mailrise
        send_email_via_smtp("Échec du dump SQL", f"Échec de la création du dump SQL: {e}")
        logging.error(f"Erreur lors de la création du dump SQL: {e}")
    
    finally:
        if conn is not None:
            conn.close()
            logging.info("Connexion à la base de données fermée.")

def send_email_via_smtp(subject, body):
    # Détails de l'e-mail
    from_email = "mehdi.fekih@edhec.com"
    to_email = "telegram@mailrise.xyz"
    
    # Création du message e-mail
    msg = MIMEText(body)
    msg["Subject"] = subject
    msg["From"] = from_email
    msg["To"] = to_email
    
    # Envoi de l'e-mail via le serveur SMTP de Mailrise
    smtp_server = "192.168.10.168"
    smtp_port = 8025
    
    with smtplib.SMTP(smtp_server, smtp_port) as server:
        server.sendmail(from_email, [to_email], msg.as_string())
        logging.info("E-mail envoyé via Mailrise.")

# Définition de la tâche du DAG
t1 = PythonOperator(
    task_id='perform_sql_dump',
    python_callable=perform_sql_dump,
    dag=dag,
)

t1
