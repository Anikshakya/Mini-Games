import 'package:flutter/material.dart';

class AppTheme {
  // Default border radius and padding values
  static const double defaultRadius = 12.0;
  static const double defaultPadding = 16.0;

  // Light Theme
  static ThemeData lightTheme({
    Color seedColor = Colors.deepPurple,
    double borderRadius = defaultRadius,
    double paddingValue = defaultPadding,
  }) {
    final colorScheme = ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.light);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: colorScheme.surface,
      shadowColor: Colors.black.withValues(alpha: 0.3), // 👈 Added for light theme
      appBarTheme: AppBarTheme(
        // backgroundColor: colorScheme.primary,
        // foregroundColor: colorScheme.onPrimary,
        elevation: 1,
        centerTitle: false,
      ),
      textTheme: Typography.blackCupertino,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          side: BorderSide(color: colorScheme.primary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        color: colorScheme.surface,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
        backgroundColor: colorScheme.surface,
      ),
    );
  }

  // Dark Theme
  static ThemeData darkTheme({
    Color seedColor = Colors.deepPurple,
    double borderRadius = defaultRadius,
    double paddingValue = defaultPadding,
  }) {
    final colorScheme = ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.dark);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colorScheme.surface,
      shadowColor: Colors.white.withValues(alpha: 0.5), // 👈 Added for dark theme
      appBarTheme: AppBarTheme(
        // backgroundColor: colorScheme.surface,
        // foregroundColor: colorScheme.onSurface,
        elevation: 1,
        centerTitle: false,
      ),
      textTheme: Typography.whiteCupertino,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          side: BorderSide(color: colorScheme.primary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        color: colorScheme.surface,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
        backgroundColor: colorScheme.surface,
      ),
    );
  }
}
