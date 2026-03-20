import 'package:flutter/material.dart';

const Color monynhaBurgundy = Color(0xFF6F1236);
const Color monynhaCopper = Color(0xFFB76A2A);
const Color monynhaSand = Color(0xFFF7F1E8);
const Color monynhaInk = Color(0xFF1E1B1C);
const Color monynhaSuccess = Color(0xFF1B7F5B);
const Color monynhaWarning = Color(0xFFE38B2C);

class AppSpacing {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

ThemeData get lightTheme {
  const colorScheme = ColorScheme.light(
    primary: monynhaBurgundy,
    secondary: monynhaCopper,
    tertiary: monynhaSuccess,
    surface: Colors.white,
    surfaceContainerHighest: Color(0xFFF2E8DD),
    error: Color(0xFFB3261E),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: Colors.white,
    onSurface: monynhaInk,
    onError: Colors.white,
    outline: Color(0xFFD8CFC5),
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: monynhaSand,
    brightness: Brightness.light,
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: monynhaBurgundy,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.06),
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: monynhaBurgundy,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: monynhaBurgundy,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: monynhaBurgundy,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: monynhaBurgundy),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD9CCC0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD9CCC0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: monynhaBurgundy, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFB3261E), width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFB3261E), width: 1.6),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    chipTheme: base.chipTheme.copyWith(
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
    textTheme: base.textTheme.copyWith(
      displaySmall: base.textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: monynhaInk,
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: monynhaInk,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: monynhaInk,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: monynhaInk,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(color: monynhaInk, height: 1.4),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(color: monynhaInk.withOpacity(0.84)),
      bodySmall: base.textTheme.bodySmall?.copyWith(color: monynhaInk.withOpacity(0.70)),
      labelLarge: base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    ),
  );
}

ThemeData get darkTheme {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFD38A4B),
      secondary: Color(0xFFF0B37D),
      tertiary: Color(0xFF69D4A8),
      surface: Color(0xFF1F1C1D),
      surfaceContainerHighest: Color(0xFF2E282A),
      error: Color(0xFFF2B8B5),
      onPrimary: monynhaInk,
      onSecondary: monynhaInk,
      onTertiary: monynhaInk,
      onSurface: Colors.white,
      onError: monynhaInk,
      outline: Color(0xFF6C6260),
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFF161314),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0, scrolledUnderElevation: 0),
    cardTheme: CardThemeData(
      color: const Color(0xFF221E20),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF221E20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF51484A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD38A4B), width: 1.5),
      ),
    ),
  );
}
