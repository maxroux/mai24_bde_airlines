FROM python:3.8-slim
WORKDIR /app
COPY code.py /app/code.py
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
CMD ["uvicorn", "code:app", "--host", "0.0.0.0", "--port", "8000"]

