#!/usr/bin/env bash
: "${GITHUB_TOKEN:?GITHUB_TOKEN não definido}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-boteco}"
echo "🔍 Variáveis ok"
