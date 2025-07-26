#!/usr/bin/env bash

if ! command -v supabase &>/dev/null; then
  echo "📦 Instalando Supabase CLI (última versão via install.sh)…"

  # Baixa e executa o script de instalação oficial
  curl -sL https://github.com/supabase/cli/releases/latest/download/install.sh | sh

  # Move o binário instalado para o PATH global (ajuste se necessário)
  mv ./bin/supabase /usr/local/bin/
fi

# Login via token, se disponível
if [[ -n "${SUPABASE_ACCESS_TOKEN:-}" ]]; then
  supabase logout || true
  supabase login --access-token "$SUPABASE_ACCESS_TOKEN"
fi

echo "✅ Supabase CLI pronto para uso."
