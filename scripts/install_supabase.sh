#!/usr/bin/env bash
if ! command -v supabase &>/dev/null; then
  echo "📦 Baixando supabase_${SUPABASE_CLI_VERSION}_linux_amd64.deb…"
  URL="https://github.com/supabase/cli/releases/download/v${SUPABASE_CLI_VERSION}/supabase_${SUPABASE_CLI_VERSION}_linux_amd64.deb"
  curl -fsSL "$URL" -o supabase.deb

  if ! dpkg-deb --info supabase.deb &>/dev/null; then
    echo "❌ Arquivo supabase.deb corrompido (possivelmente HTML)."
    cat supabase.deb
    exit 1
  fi

  dpkg -i supabase.deb || apt-get install -fy
  rm supabase.deb
fi

if [[ -n "${SUPABASE_ACCESS_TOKEN:-}" ]]; then
  supabase login --no-browser --token "$SUPABASE_ACCESS_TOKEN"
  echo "✅ Supabase autenticado"
fi
