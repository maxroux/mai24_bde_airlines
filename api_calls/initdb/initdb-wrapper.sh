#!/bin/bash
set -e

# Function to wait for PostgreSQL to be ready
wait_for_postgres() {
    until psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\q' 2>/dev/null; do
        echo "Waiting for PostgreSQL to be ready..."
        sleep 2
    done
}

# Wait for PostgreSQL to be ready
wait_for_postgres

# Run the init-user-db.sh script
./init-user-db.sh
