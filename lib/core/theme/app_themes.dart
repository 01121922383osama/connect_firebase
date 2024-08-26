import 'package:flutter/material.dart';

class AppThemes {
  static ThemeData themeData = ThemeData(
    scaffoldBackgroundColor: Colors.white70,
    primarySwatch: Colors.indigo,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.indigo,
      elevation: 0,
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: Colors.indigo.shade900,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Colors.indigo.shade900,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: Colors.indigo.shade900,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(
        color: Colors.indigo,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.indigo),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
    ),
    useMaterial3: false,
  );
}
