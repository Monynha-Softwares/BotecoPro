#!/bin/bash
set -e

git config --global user.name "Codex Monynha"
git config --global user.email "codex@monynha.com"

echo "🧠 [Codex] Iniciando bootstrap do ambiente monorepo..."

echo "🔄 Clonando repositórios BotecoPro..."
git clone https://${GITHUB_TOKEN}@github.com/marcelo-m7/BotecoPro-Backend.git ./BotecoPro-Backend
git clone https://${GITHUB_TOKEN}@github.com/marcelo-m7/BotecoPro-Apps.git ./BotecoPro-Apps

echo "✅ Repositórios prontos."
