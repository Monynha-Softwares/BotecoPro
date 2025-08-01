#!/usr/bin/env bash
set -euo pipefail

SEED=0
if [[ "${1:-}" == "--seed" ]]; then
  SEED=1
fi

SCHEMA_FILE="supabase/tables/schema.sql"
RLS_FILE="supabase/tables/rls_policies.sql"
SEED_FILE="supabase/tables/seed.sql"

for f in "$SCHEMA_FILE" "$RLS_FILE"; do
  if [[ ! -f "$f" ]]; then
    echo "Arquivo $f não encontrado" >&2
    exit 1
  fi
done

if [[ "$SEED" -eq 1 && ! -f "$SEED_FILE" ]]; then
  echo "Arquivo $SEED_FILE não encontrado" >&2
  exit 1
fi

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
cat "$SCHEMA_FILE" | docker exec -i "$CONTAINER_ID" psql -U "${POSTGRES_USER:-boteco}" -d "${POSTGRES_DB:-boteco_dev}"

# Apply RLS policies
cat "$RLS_FILE" | docker exec -i "$CONTAINER_ID" psql -U "${POSTGRES_USER:-boteco}" -d "${POSTGRES_DB:-boteco_dev}"

if [[ "$SEED" -eq 1 ]]; then
  cat "$SEED_FILE" | docker exec -i "$CONTAINER_ID" psql -U "${POSTGRES_USER:-boteco}" -d "${POSTGRES_DB:-boteco_dev}"
fi

echo "✅ Database initialized"
