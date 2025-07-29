#!/usr/bin/env bash
set -euo pipefail

POSTGRES_USER="${POSTGRES_USER:-boteco}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-boteco}"
POSTGRES_DB="${POSTGRES_DB:-boteco_pro}"

# Install Docker if missing
if ! command -v docker &>/dev/null; then
  echo "📦 Instalando Docker..."
  apt-get update -qq
  apt-get install -y -qq docker.io
fi

# Start Postgres container if not running
if ! docker ps --format '{{.Names}}' | grep -q botecopro-postgres; then
  echo "🚀 Iniciando container Postgres..."
  docker run -d --name botecopro-postgres \
    -e POSTGRES_USER="$POSTGRES_USER" \
    -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
    -e POSTGRES_DB="$POSTGRES_DB" \
    -p 5432:5432 \
    -v botecopro_data:/var/lib/postgresql/data \
    postgres:15
else
  echo "✅ Container Postgres já está em execução"
fi
