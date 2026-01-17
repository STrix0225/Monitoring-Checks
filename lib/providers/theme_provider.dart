import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  
  ThemeData get currentTheme => _lightTheme;
  ThemeData get darkTheme => _darkTheme;
  ThemeMode get themeMode => _themeMode;

  static final Color _primaryGreen = const Color.fromARGB(255, 95, 142, 95);

  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: _primaryGreen,
    colorScheme: ColorScheme.light(
      primary: _primaryGreen,
      secondary: _primaryGreen,
      surface: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _primaryGreen,
      elevation: 0,
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: _primaryGreen,
    colorScheme: ColorScheme.dark(
      primary: _primaryGreen,
      secondary: _primaryGreen,
      surface: Colors.grey[900]!,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _primaryGreen,
      elevation: 0,
    ),
  );

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
