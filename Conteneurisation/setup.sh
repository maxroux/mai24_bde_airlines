#!/bin/bash

# Build and start services defined in docker-compose1.yml
echo "Building and starting services from docker-compose1.yml..."
docker-compose -f docker-compose1.yml build
docker-compose -f docker-compose1.yml up -d

# Wait for services in docker-compose1.yml to be healthy or ready
echo "Waiting for services from docker-compose1.yml to be ready..."
docker-compose -f docker-compose1.yml logs -f &
wait_for_services1() {
  while ! docker-compose -f docker-compose1.yml ps | grep -q 'Up (healthy)'; do
    sleep 2
  done
}
wait_for_services1

# Build and start services defined in docker-compose2.yml
echo "Building and starting services from docker-compose2.yml..."
docker-compose -f docker-compose2.yml build
docker-compose -f docker-compose2.yml up -d

# Wait for services in docker-compose2.yml to be healthy or ready
echo "Waiting for services from docker-compose2.yml to be ready..."
docker-compose -f docker-compose2.yml logs -f &
wait_for_services2() {
  while ! docker-compose -f docker-compose2.yml ps | grep -q 'Up (healthy)'; do
    sleep 2
  done
}
wait_for_services2

# Build and start services defined in docker-compose3.yml
echo "Building and starting services from docker-compose3.yml..."
docker-compose -f docker-compose3.yml build
docker-compose -f docker-compose3.yml up -d

# Wait for services in docker-compose3.yml to be healthy or ready
echo "Waiting for services from docker-compose3.yml to be ready..."
docker-compose -f docker-compose3.yml logs -f &
wait_for_services3() {
  while ! docker-compose -f docker-compose3.yml ps | grep -q 'Up (healthy)'; do
    sleep 2
  done
}
wait_for_services3

echo "All services are up and running."

