import smtplib
from email.mime.text import MIMEText
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime, timedelta

# Default arguments
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Define the DAG
dag = DAG(
    'send_mailrise_notification',
    default_args=default_args,
    description='A simple DAG to send Mailrise notification using smtplib',
    schedule_interval=timedelta(days=1),
    start_date=datetime(2023, 1, 1),
    catchup=False,
)

def send_email_via_smtp():
    # Email details
    from_email = "mehdi.fekih@edhec.com"
    to_email = "telegram@mailrise.xyz"
    subject = "Test Mailrise"
    body = "This is a test email."

    # Create the email message
    msg = MIMEText(body)
    msg["Subject"] = subject
    msg["From"] = from_email
    msg["To"] = to_email

    # Send the email via Mailrise SMTP server
    smtp_server = "192.168.10.168"
    smtp_port = 8025

    with smtplib.SMTP(smtp_server, smtp_port) as server:
        server.sendmail(from_email, [to_email], msg.as_string())

# Define the task
send_email = PythonOperator(
    task_id='send_email',
    python_callable=send_email_via_smtp,
    dag=dag,
)

send_email
