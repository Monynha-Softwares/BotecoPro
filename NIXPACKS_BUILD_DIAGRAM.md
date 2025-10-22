# Nixpacks Build Process Diagram

## 🔄 Complete Build Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     RAILWAY.APP / NIXPACKS                      │
│                    Automatic Build Process                      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Phase 1: SETUP                                                 │
│  ━━━━━━━━━━━━━━━━                                               │
│  Nixpacks detects nixpacks.toml                                 │
│  Installs system packages:                                      │
│    - wget (for downloading)                                     │
│    - git (for version control)                                  │
│    - bash (for scripts)                                         │
│    - curl (for HTTP requests)                                   │
│    - xz (for compression)                                       │
│    - python3 (for web server)                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Phase 2: INSTALL                                               │
│  ━━━━━━━━━━━━━━━━━                                              │
│  Runs: ./nixpacks-setup.sh install                              │
│                                                                 │
│  Step 1: Download Flutter SDK                                   │
│    ├─ Fetch flutter_linux_3.24.5-stable.tar.xz                 │
│    ├─ URL: storage.googleapis.com/flutter_infra_release/...    │
│    └─ Size: ~600 MB                                             │
│                                                                 │
│  Step 2: Extract Flutter                                        │
│    ├─ Extract tar.xz archive                                    │
│    ├─ Place in ./flutter/                                       │
│    └─ Add flutter/bin to PATH                                   │
│                                                                 │
│  Step 3: Configure Flutter                                      │
│    ├─ flutter --version (verify installation)                   │
│    ├─ flutter config --no-analytics                            │
│    └─ flutter config --enable-web                              │
│                                                                 │
│  Step 4: Install Dependencies                                   │
│    └─ flutter pub get (from pubspec.yaml)                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Phase 3: BUILD                                                 │
│  ━━━━━━━━━━━━━━                                                 │
│  Runs: ./nixpacks-setup.sh build                                │
│                                                                 │
│  Step 1: Compile Application                                    │
│    ├─ flutter build web --release                              │
│    ├─ Compiles Dart to JavaScript                              │
│    ├─ Optimizes for production                                  │
│    └─ Minifies assets                                           │
│                                                                 │
│  Step 2: Generate Output                                        │
│    └─ Creates build/web/ directory                             │
│        ├─ index.html                                            │
│        ├─ main.dart.js (~2.8 MB)                                │
│        ├─ flutter.js                                            │
│        ├─ canvaskit/ (~640 KB)                                  │
│        └─ assets/                                               │
│                                                                 │
│  Total Build Size: ~3.8 MB                                      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Phase 4: START                                                 │
│  ━━━━━━━━━━━━━                                                  │
│  Runs: ./nixpacks-setup.sh start                                │
│                                                                 │
│  Step 1: Navigate to build/web                                  │
│  Step 2: Start Python HTTP Server                               │
│    ├─ python3 -m http.server $PORT                             │
│    ├─ PORT set by Railway (e.g., 3000)                         │
│    └─ Serves static files                                       │
│                                                                 │
│  Server Running ✅                                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  DEPLOYMENT COMPLETE 🚀                                         │
│  ━━━━━━━━━━━━━━━━━━━━━━                                        │
│  Application accessible at:                                     │
│  https://your-app.up.railway.app                                │
└─────────────────────────────────────────────────────────────────┘
```

## 📊 Time Breakdown

```
┌─────────────────┬──────────────┬────────────────┐
│ Phase           │ First Build  │ Cached Build   │
├─────────────────┼──────────────┼────────────────┤
│ Setup           │ ~30 seconds  │ ~10 seconds    │
│ Install         │ ~4 minutes   │ ~1 minute      │
│ Build           │ ~3 minutes   │ ~2 minutes     │
│ Start           │ ~5 seconds   │ ~5 seconds     │
├─────────────────┼──────────────┼────────────────┤
│ TOTAL           │ ~8 minutes   │ ~3 minutes     │
└─────────────────┴──────────────┴────────────────┘
```

## 🔍 Key Components

### nixpacks.toml
```
Configuration file that defines:
├─ Variables (FLUTTER_VERSION)
├─ System packages to install
├─ Install commands
├─ Build commands
└─ Start command
```

### nixpacks-setup.sh
```
Multi-purpose script with modes:
├─ install: Downloads Flutter, runs pub get
├─ build: Compiles web application
└─ start: Serves static files
```

## 🌊 Data Flow

```
Source Code (GitHub)
        │
        ▼
    Railway Platform
        │
        ├─ Clone repository
        ├─ Detect nixpacks.toml
        │
        ▼
    Nixpacks Builder
        │
        ├─ Run setup phase
        ├─ Run install phase
        ├─ Run build phase
        │
        ▼
    Container Image
        │
        ├─ Flutter SDK
        ├─ Built web app (build/web/)
        ├─ Python runtime
        │
        ▼
    Running Container
        │
        └─ HTTP server on PORT
               │
               ▼
        Public URL (HTTPS)
```

## 🔧 Environment Variables

```
┌──────────────────┬─────────────┬─────────────────────┐
│ Variable         │ Default     │ Set By              │
├──────────────────┼─────────────┼─────────────────────┤
│ FLUTTER_VERSION  │ 3.24.5      │ nixpacks.toml       │
│ PORT             │ 8080        │ Railway (automatic) │
│ PATH             │ Enhanced    │ nixpacks-setup.sh   │
└──────────────────┴─────────────┴─────────────────────┘
```

## 📁 Directory Structure During Build

```
/app (Railway workspace)
│
├─ Source files (from Git)
│  ├─ lib/
│  ├─ web/
│  ├─ pubspec.yaml
│  ├─ nixpacks.toml
│  └─ nixpacks-setup.sh
│
├─ flutter/ (created during install)
│  ├─ bin/
│  │  ├─ flutter
│  │  └─ dart
│  ├─ packages/
│  └─ ...
│
└─ build/web/ (created during build)
   ├─ index.html
   ├─ main.dart.js
   ├─ flutter.js
   ├─ canvaskit/
   └─ assets/
      └─ ...
```

## 🚦 Error Handling

```
┌─────────────────────────────────────┐
│ If Flutter SDK download fails:     │
│   └─ Check network connectivity    │
│   └─ Verify FLUTTER_VERSION        │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ If pub get fails:                  │
│   └─ Check pubspec.yaml             │
│   └─ Verify dependency versions    │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ If build fails:                    │
│   └─ Check Flutter compatibility   │
│   └─ Review build logs              │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ If server won't start:             │
│   └─ Verify build/web/ exists      │
│   └─ Check PORT variable            │
└─────────────────────────────────────┘
```

## 🎯 Success Indicators

```
✅ Setup Phase:
   └─ "System packages installed"

✅ Install Phase:
   └─ "Flutter SDK version X.Y.Z"
   └─ "Install phase completed"

✅ Build Phase:
   └─ "Build phase completed"
   └─ "build/web/ directory exists"

✅ Start Phase:
   └─ "Starting HTTP server on port XXXX"

✅ Deployment:
   └─ "Deployment successful"
   └─ Public URL accessible
```

---

**Diagram Version**: 1.0
**Last Updated**: October 22, 2025
**Status**: Production Ready
