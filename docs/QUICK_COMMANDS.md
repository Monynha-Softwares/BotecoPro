# Quick Commands - Supabase Integration

## Run with SharedPreferences (default)
```powershell
flutter pub get
flutter run -d web
```

## Run with Supabase
```powershell
# 1. Configure .env first (copy from .env.example)
# Add SUPABASE_URL and SUPABASE_ANON_KEY

# 2. Run with Supabase flag
flutter run -d web --dart-define=USE_SUPABASE=true
```

## Build for production

### Web (SharedPreferences)
```powershell
flutter build web --release
```

### Web (Supabase)
```powershell
flutter build web --release --dart-define=USE_SUPABASE=true
```

## Test database connection
```powershell
# After setting up .env, run a quick test
flutter run -d web --dart-define=USE_SUPABASE=true

# Check browser console for:
# "Supabase initialized successfully" (success)
# or error messages if credentials are invalid
```

## Dependencies
```powershell
# Install/update dependencies
flutter pub get

# Check for outdated packages
flutter pub outdated

# Upgrade all packages
flutter pub upgrade
```
