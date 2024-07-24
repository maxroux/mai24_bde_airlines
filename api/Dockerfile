FROM python:3.8-slim
WORKDIR /app
COPY api /app/api
COPY api/requirements.txt /app/requirements.txt
COPY api/code.py /app/code.py
RUN pip install --no-cache-dir -r requirements.txt
CMD ["uvicorn", "api.code:appe", "--host", "0.0.0.0", "--port", "8000","--reload"]

