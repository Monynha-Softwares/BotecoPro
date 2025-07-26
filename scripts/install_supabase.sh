#!/usr/bin/env bash
set -euo pipefail

if ! command -v supabase &>/dev/null; then
  echo "📦 Instalando Supabase CLI (última versão via install.sh)…"

  # Baixa e salva o instalador em disco para melhor controle
  curl -sL https://github.com/supabase/cli/releases/latest/download/install.sh -o install_supabase.sh

  # Verifica se é HTML (erro disfarçado)
  if grep -q '<!DOCTYPE html>' install_supabase.sh; then
    echo "❌ Erro: O download de install.sh falhou. Conteúdo HTML recebido."
    cat install_supabase.sh
    exit 1
  fi

  # Executa o instalador
  bash install_supabase.sh

  # Move o binário instalado (caso esteja presente)
  if [[ -f ./bin/supabase ]]; then
    chmod +x ./bin/supabase
    mv ./bin/supabase /usr/local/bin/
  fi

  rm -f install_supabase.sh
fi

# Autentica CLI se token estiver definido
if [[ -n "${SUPABASE_ACCESS_TOKEN:-}" ]]; then
  supabase logout || true
  supabase login --access-token "$SUPABASE_ACCESS_TOKEN"
fi

echo "✅ Supabase CLI pronto para uso."
# Verifica a versão instalada
supabase --version || true
echo "📦 Supabase CLI instalado com sucesso."