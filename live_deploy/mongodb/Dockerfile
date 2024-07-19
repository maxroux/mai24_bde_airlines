FROM mongo:latest

RUN apt-get update && apt-get install -y nodejs npm

# Copy initialization scripts into the container
# COPY ./live_deploy/mongodb/init-mongo.js /docker-entrypoint-initdb.d/
# COPY ./data/json/departure_result.json /docker-entrypoint-initdb.d/

# Copy initialization scripts into the container
COPY ./init-mongo.js /docker-entrypoint-initdb.d/
COPY ./departure_result.json /docker-entrypoint-initdb.d/
