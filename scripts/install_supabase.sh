#!/usr/bin/env bash

if ! command -v supabase &>/dev/null; then
  echo "📦 Instalando Supabase CLI versão $SUPABASE_CLI_VERSION…"

  SUPABASE_CLI_URL="https://github.com/supabase/cli/releases/download/v${SUPABASE_CLI_VERSION}/supabase_${SUPABASE_CLI_VERSION}_linux_amd64.tar.gz"
  curl -sL "$SUPABASE_CLI_URL" -o supabase.tar.gz

  # Verificar se o arquivo contém HTML (erro disfarçado de download)
  if head -n 1 supabase.tar.gz | grep -q '<'; then
    echo "❌ Erro: Falha no download da versão $SUPABASE_CLI_VERSION (HTML recebido ao invés de tar.gz)"
    cat supabase.tar.gz
    exit 1
  fi

  tar -xzf supabase.tar.gz
  chmod +x supabase
  mv supabase /usr/local/bin/
  rm supabase.tar.gz
fi

if [[ -n "${SUPABASE_ACCESS_TOKEN:-}" ]]; then
  supabase logout || true
  supabase login --access-token "$SUPABASE_ACCESS_TOKEN"
fi

echo "✅ Supabase CLI pronto para uso."
