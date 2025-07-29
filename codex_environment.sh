#!/usr/bin/env bash
set -euo pipefail

#────────────────── 0. Verifica se está sendo executado como root
if [[ $EUID -ne 0 ]]; then
  echo "✋ Rode com sudo/root"
  exit 1
fi

#────────────────── 1. Instala dependências essenciais
apt-get update -qq
apt-get install -y -qq file unzip git curl dpkg \
  openjdk-17-jdk clang cmake ninja-build pkg-config libgtk-3-dev \
  chromium-browser android-sdk docker.io

#────────────────── 2. Verifica variáveis de ambiente obrigatórias
: "${GITHUB_TOKEN:?GITHUB_TOKEN não definido}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-boteco}"

echo "🔍 Variáveis ok"

#────────────────── 3. Configura Git global
git config --global user.name  "Codex Monynha"
git config --global user.email "codex@monynha.com"
echo "✅ Git configurado"


#────────────────── 4. Instala Docker/Postgres local
if ! command -v docker &>/dev/null; then
  echo "📦 Instalando Docker..."
  apt-get update -qq
  apt-get install -y -qq docker.io
fi

if ! docker ps --format '{{.Names}}' | grep -q botecopro-postgres; then
  echo "🚀 Iniciando container Postgres..."
  docker run -d --name botecopro-postgres \
    -e POSTGRES_USER=boteco \
    -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
    -e POSTGRES_DB=boteco_pro \
    -p 5432:5432 \
    -v botecopro_data:/var/lib/postgresql/data \
    postgres:15
else
  echo "✅ Container Postgres já está em execução"
fi

#────────────────── 5. Instala Flutter SDK (se necessário)
if ! command -v flutter &>/dev/null; then
  echo "📦 Instalando Flutter stable…"
  git clone --depth 1 https://github.com/flutter/flutter.git -b stable "$HOME/flutter"
  export PATH="$HOME/flutter/bin:$PATH"
  echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
fi

# Configura Android SDK
export ANDROID_HOME=/usr/lib/android-sdk
export ANDROID_SDK_ROOT=/usr/lib/android-sdk
echo 'export ANDROID_HOME=/usr/lib/android-sdk' >> ~/.bashrc
echo 'export ANDROID_SDK_ROOT=/usr/lib/android-sdk' >> ~/.bashrc

# Instala ferramentas de linha de comando se ausentes
if [[ ! -x "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" ]]; then
  mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools"
  curl -fsSL https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -o cmd.zip
  unzip -q cmd.zip -d "$ANDROID_SDK_ROOT/cmdline-tools/"
  mv "$ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools" "$ANDROID_SDK_ROOT/cmdline-tools/latest"
  rm cmd.zip
fi

yes | "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" --licenses >/dev/null
yes | "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-34" >/dev/null

export CHROME_EXECUTABLE=/usr/bin/chromium-browser
echo 'export CHROME_EXECUTABLE=/usr/bin/chromium-browser' >> ~/.bashrc

flutter doctor -v || true
echo "✅ Flutter instalado"

#────────────────── 6. Clona repositórios do projeto
echo "🔄 Clonando repositórios BotecoPro…"
if [[ ! -d BotecoPro-Backend ]]; then
  git clone "https://${GITHUB_TOKEN}@github.com/marcelo-m7/BotecoPro-Backend.git" BotecoPro-Backend
fi
if [[ ! -d BotecoPro-Apps ]]; then
  git clone "https://${GITHUB_TOKEN}@github.com/marcelo-m7/BotecoPro-Apps.git" BotecoPro-Apps
fi
echo "✅ Repositórios clonados"

#────────────────── ✅ Fim
echo "🚀 Ambiente Monynha pronto para desenvolvimento!"
