#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "✋ Rode com sudo/root"
  exit 1
fi

apt-get update -qq
apt-get install -y -qq file unzip git curl dpkg

echo "🧠 Iniciando configuração do ambiente Monynha..."
source ./scripts/check_env.sh
source ./scripts/setup_git.sh
source ./scripts/install_supabase.sh
source ./scripts/install_flutter.sh
source ./scripts/clone_repos.sh

echo "✅ Ambiente pronto!"
