#!/usr/bin/env bash
set -euo pipefail

# Verifica se o script está sendo executado como root
if [[ $EUID -ne 0 ]]; then
  echo "🚨 Este script deve ser executado como root. Use 'sudo' par
a executar o script."
  exit 1
fi

echo "🧠 [Codex] Instalando dependências do ambiente Monynha..."
apt-get update && apt-get install -y file && apt-get install -y unzip && apt-get install -y git && apt-get install -y curl

echo "🧠 [Codex] Iniciando configuração do ambiente Monynha…"

source ./scripts/check_env.sh
source ./scripts/setup_git.sh
source ./scripts/install_supabase.sh
source ./scripts/install_flutter.sh
source ./scripts/clone_repos.sh

echo "🚀 Ambiente Monynha configurado com sucesso!"
