import 'package:flutter/material.dart';

/// Provider managing application theme state (light / dark mode)
/// and custom [ThemeData] configurations.
class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  /// Returns whether the current active theme is dark mode.
  bool get isDark => _isDark;

  /// Returns the corresponding [ThemeMode] enum.
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  /// Toggles between light and dark themes.
  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  /// Sets dark theme state directly.
  void setDarkTheme(bool isDark) {
    if (_isDark == isDark) return;
    _isDark = isDark;
    notifyListeners();
  }

  /// Custom light theme configuration with Material 3 design.
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: const Color(0xFF2E3192), // Premium deep blue
      scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Soft premium grey
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F7FA),
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
      ),
      fontFamily: 'Poppins',
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: const Color(0xFF2E3192),
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2E3192), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF2E3192),
        unselectedItemColor: Colors.black38,
      ),
    );
  }

  /// Custom dark theme configuration with Material 3 design.
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: const Color(0xFF4A65FF), // Brighter blue for dark mode
      scaffoldBackgroundColor: const Color(0xFF0F1115), // Very deep charcoal
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F1115),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
      ),
      fontFamily: 'Poppins',
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1C1F26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: const Color(0xFF4A65FF),
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1C1F26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF4A65FF), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: Color(0xFF1C1F26),
        selectedItemColor: Color(0xFF4A65FF),
        unselectedItemColor: Colors.white38,
      ),
    );
  }
}

