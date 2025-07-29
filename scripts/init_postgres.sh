#!/usr/bin/env bash
set -euo pipefail

# Ensure Postgres container is running
if command -v docker compose &>/dev/null; then
  docker compose up -d db
  CONTAINER_ID=$(docker compose ps -q db)
else
  docker-compose up -d db
  CONTAINER_ID=$(docker-compose ps -q db)
fi

# Wait until Postgres is ready
until docker exec "$CONTAINER_ID" pg_isready -U "${POSTGRES_USER:-boteco}" >/dev/null 2>&1; do
  echo "Waiting for Postgres..."
  sleep 1
done

# Load schema
cat database/postgres/schema.sql | docker exec -i "$CONTAINER_ID" psql -U "${POSTGRES_USER:-boteco}" -d "${POSTGRES_DB:-boteco_dev}"

echo "✅ Database initialized"
