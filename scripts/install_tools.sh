#!/bin/bash
# Instalador de dependências de desenvolvimento

# Exemplo: instalar supabase CLI
if ! command -v supabase >/dev/null; then
  npm install -g supabase
fi
