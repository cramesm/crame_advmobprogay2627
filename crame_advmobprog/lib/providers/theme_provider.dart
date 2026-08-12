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
      colorSchemeSeed: Colors.indigo,
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      fontFamily: 'Poppins',
    );
  }

  /// Custom dark theme configuration with Material 3 design.
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: Colors.indigo,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      fontFamily: 'Poppins',
    );
  }
}

