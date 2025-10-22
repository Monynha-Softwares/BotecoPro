#!/bin/bash
# Nixpacks helper script for BotecoPro Flutter Web Application

set -e

FLUTTER_VERSION="${FLUTTER_VERSION:-3.24.5}"
FLUTTER_DIR="$PWD/flutter"
FLUTTER_BIN="$FLUTTER_DIR/bin"

# Add Flutter to PATH for this script
export PATH="$FLUTTER_BIN:$PATH"

case "$1" in
    install)
        echo "📦 Installing Flutter SDK ${FLUTTER_VERSION}..."
        
        # Download Flutter SDK if not already present
        if [ ! -d "$FLUTTER_DIR" ]; then
            echo "⬇️  Downloading Flutter SDK..."
            curl -o flutter.tar.xz "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
            
            echo "📂 Extracting Flutter SDK..."
            tar xf flutter.tar.xz
            rm flutter.tar.xz
        else
            echo "✅ Flutter SDK already exists"
        fi
        
        echo "🔧 Configuring Flutter..."
        flutter --version
        flutter config --no-analytics
        flutter config --enable-web
        
        echo "📥 Installing dependencies..."
        flutter pub get
        
        echo "✅ Install phase completed"
        ;;
        
    build)
        echo "🏗️  Building Flutter web application..."
        
        if [ ! -d "$FLUTTER_DIR" ]; then
            echo "❌ Flutter SDK not found. Run install phase first."
            exit 1
        fi
        
        echo "🔨 Running flutter build web --release..."
        flutter build web --release
        
        echo "📊 Build output:"
        ls -lh build/web/
        
        echo "✅ Build phase completed"
        ;;
        
    start)
        echo "🚀 Starting web server..."
        
        if [ ! -d "build/web" ]; then
            echo "❌ Build directory not found. Run build phase first."
            exit 1
        fi
        
        cd build/web
        
        # Use PORT environment variable if set, otherwise default to 8080
        PORT="${PORT:-8080}"
        
        echo "🌐 Starting HTTP server on port $PORT..."
        python3 -m http.server "$PORT"
        ;;
        
    *)
        echo "Usage: $0 {install|build|start}"
        exit 1
        ;;
esac
