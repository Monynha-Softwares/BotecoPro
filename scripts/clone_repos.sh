#!/usr/bin/env bash
echo "🔄 Clonando repositórios BotecoPro…"
git clone "https://${GITHUB_TOKEN}@github.com/marcelo-m7/BotecoPro-Backend.git" BotecoPro-Backend
git clone "https://${GITHUB_TOKEN}@github.com/marcelo-m7/BotecoPro-Apps.git" BotecoPro-Apps
echo "✅ Repositórios clonados"
