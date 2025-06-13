#!/bin/sh
set -e

# Function to check if database is ready
wait_for_postgres() {
  echo "Waiting for postgres..."
  until pg_isready -h ${PG_DATABASE_HOST:-db} -p ${PG_DATABASE_PORT:-5432} -U ${PG_DATABASE_USER:-postgres}
  do
    echo "Postgres is not ready yet..."
    sleep 1
  done
  echo "Postgres is ready!"
}

# Wait for database to be ready
wait_for_postgres

# Run database migrations
echo "Running database migrations..."
yarn database:migrate:prod || echo "Migration might have already run"

# Run database seeds if first time
echo "Running database seeds..."
yarn database:seed:prod || echo "Seeding might have already run"

# Execute the main command
exec "$@"