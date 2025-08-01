#!/usr/bin/env bash
echo "🔄 Clonando repositórios BotecoPro…"
if [ ! -d BotecoPro-Backend ]; then
  git clone "https://${GITHUB_TOKEN}@github.com/marcelo-m7/BotecoPro-Backend.git" BotecoPro-Backend
else
  echo "📂 BotecoPro-Backend já existe, pulando clone"
fi

if [ ! -d BotecoPro-Apps ]; then
  git clone "https://${GITHUB_TOKEN}@github.com/marcelo-m7/BotecoPro-Apps.git" BotecoPro-Apps
else
  echo "📂 BotecoPro-Apps já existe, pulando clone"
fi
echo "✅ Repositórios clonados"
