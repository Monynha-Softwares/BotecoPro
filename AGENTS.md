# BotecoPro Monorepo Notes

This repo contains the Flutter application. Backend sources are cloned in the
`BotecoPro-Backend` directory but are not tracked by this repository.

## Recent changes
- Added push and Supabase related dependencies to `pubspec.yaml`.
- Updated `lib/main.dart` to load Supabase credentials from environment variables
  using `flutter_dotenv` and to pass the initialization future to the UI.
- `AuthWrapper` now accepts an optional initialization `Future` to display a
  loader until Supabase is ready.
- Marked completed items inside `TASKS.md`.

## Next steps
- Implement the remaining Supabase schema migration inside the backend
  repository (not versioned here).
- Finish replacing the old local database service with Supabase calls across the
  app.
