import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider({String? initialTheme}) {
    if (initialTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else if (initialTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.light) await prefs.setString('theme_mode', 'light');
    else if (mode == ThemeMode.dark) await prefs.setString('theme_mode', 'dark');
    else await prefs.remove('theme_mode');
  }
}
