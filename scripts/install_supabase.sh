#!/usr/bin/env bash
set -euo pipefail

if ! command -v supabase &>/dev/null; then
  echo "📦 Instalando Supabase CLI via pacote .deb (Linux)..."

  curl -sL https://github.com/supabase/cli/releases/latest/download/supabase_amd64.deb -o supabase.deb

  if grep -q '<html' supabase.deb; then
    echo "❌ Erro: Falha no download do pacote .deb. Conteúdo inválido recebido."
    cat supabase.deb
    exit 1
  fi

  apt-get update && apt-get install -y ./supabase.deb
  rm -f supabase.deb
fi

# Autentica se token estiver disponível
if [[ -n "${SUPABASE_ACCESS_TOKEN:-}" ]]; then
  supabase logout || true
  supabase login --access-token "$SUPABASE_ACCESS_TOKEN"
fi

echo "✅ Supabase CLI instalado e pronto."
