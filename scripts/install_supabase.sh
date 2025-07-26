#!/usr/bin/env bash

if ! command -v supabase &>/dev/null; then
  echo "📦 Instalando Supabase CLI versão $SUPABASE_CLI_VERSION…"

  SUPABASE_CLI_URL="https://github.com/supabase/cli/releases/download/v${SUPABASE_CLI_VERSION}/supabase_${SUPABASE_CLI_VERSION}_linux_amd64.zip"
  curl -sL "$SUPABASE_CLI_URL" -o supabase.zip

  # Verificar se o conteúdo baixado não é HTML
  if head -n 1 supabase.zip | grep -q '<'; then
    echo "❌ Erro: Falha no download da versão $SUPABASE_CLI_VERSION (HTML recebido ao invés de zip)"
    cat supabase.zip
    exit 1
  fi

  unzip supabase.zip
  chmod +x supabase
  mv supabase /usr/local/bin/
  rm supabase.zip
fi

if [[ -n "${SUPABASE_ACCESS_TOKEN:-}" ]]; then
  supabase logout || true
  supabase login --access-token "$SUPABASE_ACCESS_TOKEN"
fi

echo "✅ Supabase CLI pronto para uso."
