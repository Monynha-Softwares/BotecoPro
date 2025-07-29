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
  chromium-browser android-sdk

#────────────────── 2. Verifica variáveis de ambiente obrigatórias
: "${SUPABASE_URL:?SUPABASE_URL não definido}"
: "${SUPABASE_ANON_KEY:?SUPABASE_ANON_KEY não definido}"
: "${SUPABASE_PROJECT_ID:?SUPABASE_PROJECT_ID não definido}"
: "${GITHUB_TOKEN:?GITHUB_TOKEN não definido}"
SUPABASE_CLI_VERSION="${SUPABASE_CLI_VERSION:-2.31.8}"  # padrão ou sobrescrevível

echo "🔍 Variáveis ok  | CLI v$SUPABASE_CLI_VERSION"

#────────────────── 3. Configura Git global
git config --global user.name  "Codex Monynha"
git config --global user.email "codex@monynha.com"
echo "✅ Git configurado"

#────────────────── 4. Instala Supabase CLI (formato .deb)
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

#────────────────── 4.1 Login no Supabase CLI (via token)
if [[ -n "${SUPABASE_ACCESS_TOKEN:-}" ]]; then
  supabase login --token "$SUPABASE_ACCESS_TOKEN" >/dev/null
  echo "✅ Supabase autenticado"
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
