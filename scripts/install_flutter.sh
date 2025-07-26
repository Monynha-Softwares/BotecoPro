#!/usr/bin/env bash
if ! command -v flutter &>/dev/null; then
  echo "📦 Instalando Flutter stable…"
  git clone --depth 1 https://github.com/flutter/flutter.git -b stable "$HOME/flutter"
  export PATH="$HOME/flutter/bin:$PATH"
  echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
fi
flutter doctor -v || true
echo "✅ Flutter instalado"
