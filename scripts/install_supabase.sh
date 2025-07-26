#!/usr/bin/env bash
set -euo pipefail

if ! command -v supabase &>/dev/null; then
  echo "📦 Instalando Supabase CLI via pacote .deb (Linux)..."

  curl -sL https://github.com/supabase/cli/releases/latest/download/supabase_amd64.deb -o supabase.deb

  # Verifica se o arquivo é realmente um .deb válido (não HTML)
  if head -n 1 supabase.deb | grep -q '<'; then
    echo "❌ Erro: supabase.deb não é um arquivo .deb válido (parece HTML)."
    cat supabase.deb
    exit 1
  fi

  # Instala com dpkg (não apt), pois o arquivo está local
  dpkg -i supabase.deb || apt-get install -fy

  rm -f supabase.deb
fi

# Autentica se variável estiver presente
if [[ -n "${SUPABASE_ACCESS_TOKEN:-}" ]]; then
  supabase logout || true
  supabase login --access-token "$SUPABASE_ACCESS_TOKEN"
fi

echo "✅ Supabase CLI instalado com sucesso."
