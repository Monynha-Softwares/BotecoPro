#!/usr/bin/env bash
# Inicia o contêiner do Postgres definido no docker-compose.yml
if command -v docker compose &>/dev/null; then
  docker compose up -d db
else
  docker-compose up -d db
fi
