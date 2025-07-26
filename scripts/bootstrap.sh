#!/usr/bin/env bash
set -euo pipefail

echo "🧠 [Codex] Iniciando configuração do ambiente Monynha…"

source ./scripts/check_env.sh
source ./scripts/setup_git.sh
source ./scripts/install_supabase.sh
source ./scripts/install_flutter.sh
source ./scripts/clone_repos.sh

echo "🚀 Ambiente Monynha configurado com sucesso!"
