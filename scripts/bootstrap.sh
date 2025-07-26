#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────
# 0. Verifica se está sendo executado como root
# ─────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
  echo "🚨 Este script deve ser executado como root. Use 'sudo' para executá-lo."
  exit 1
fi

# ─────────────────────────────────────────────────────────
# 1. Instala pacotes essenciais
# ─────────────────────────────────────────────────────────
echo "🧠 [Codex] Instalando dependências do ambiente Monynha..."
apt-get update
apt-get install -y file unzip git curl

# ─────────────────────────────────────────────────────────
# 2. Executa os módulos de configuração
# ─────────────────────────────────────────────────────────
echo "🧠 [Codex] Iniciando configuração do ambiente Monynha…"

source ./scripts/check_env.sh
source ./scripts/setup_git.sh
source ./scripts/install_supabase.sh
source ./scripts/install_flutter.sh
source ./scripts/clone_repos.sh

echo "🚀 Ambiente Monynha configurado com sucesso!"
