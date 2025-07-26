#!/usr/bin/env bash
: "${SUPABASE_URL:?SUPABASE_URL não definido}"
: "${SUPABASE_ANON_KEY:?SUPABASE_ANON_KEY não definido}"
: "${SUPABASE_PROJECT_ID:?SUPABASE_PROJECT_ID não definido}"
: "${SUPABASE_CLI_VERSION:?SUPABASE_CLI_VERSION não definido}"
: "${GITHUB_TOKEN:?GITHUB_TOKEN não definido}"
# Opcional: : "${SUPABASE_SERVICE_ROLE_KEY:?SUPABASE_SERVICE_ROLE_KEY não definido}"

echo "🔍 Variáveis de ambiente verificadas com sucesso."
