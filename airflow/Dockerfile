FROM apache/airflow:2.8.1
USER airflow
COPY requirements.txt /requirements.txt
RUN pip install -r /requirements.txt
USER root
RUN apt-get update && apt-get install -y \
    libgomp1 && pip3 install --no-cache-dir mlflow==2.9.2
USER airflow
