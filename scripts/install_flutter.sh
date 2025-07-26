#!/usr/bin/env bash

if ! command -v flutter &>/dev/null; then
  echo "📦 Instalando Flutter SDK (canal stable)…"
  FLUTTER_DIR="$HOME/flutter"
  git clone --depth 1 https://github.com/flutter/flutter.git -b stable "$FLUTTER_DIR"
  export PATH="$FLUTTER_DIR/bin:$PATH"
  echo 'export PATH="$HOME/flutter/bin:$PATH"' >> "$HOME/.bashrc"
fi

flutter doctor -v || true
echo "✅ Flutter instalado e validado."
