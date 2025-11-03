// lib/core/config/database_config.dart
//
/// Database configuration - toggle between SharedPreferences and Supabase
///
/// Set `useSupabase` to true to use remote Supabase backend
/// Set `useSupabase` to false to use local SharedPreferences backend (default)
///
library;

class DatabaseConfig {
  /// Toggle between SharedPreferences (false) and Supabase (true)
  /// Default: false (SharedPreferences for backward compatibility)
  static const bool useSupabase = bool.fromEnvironment(
    'USE_SUPABASE',
    defaultValue: false,
  );

  /// Supabase configuration (only used when useSupabase = true)
  /// These can be set via .env file or as compile-time constants
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
}
