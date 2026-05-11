import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF6C5CE7);
  static const secondary = Color(0xFFA29BFE);
  static const accent = Color(0xFF00B894);
  static const dark = Color(0xFF1E1E2E);
  static const surface = Color(0xFF2A2A3E);
  static const codeBackground = Color(0xFF1A1A2E);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: primary,
          secondary: secondary,
          surface: surface,
          onPrimary: Colors.white,
        ),
        scaffoldBackgroundColor: dark,
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
        ),
        cardTheme: CardThemeData(
          color: surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.white38),
        ),
      );
}
