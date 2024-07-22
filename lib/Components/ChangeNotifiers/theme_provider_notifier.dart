import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeProvider with ChangeNotifier {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    loadThemeMode();
  }

  void loadThemeMode() async {
    String? themeModeString = await storage.read(key: 'themeMode');
    if (themeModeString != null) {
      switch (themeModeString) {
        case 'Light Mode':
          _themeMode = ThemeMode.light;
          break;
        case 'Dark Mode':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    }
    notifyListeners();
  }

  set themeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    storage.write(key: 'themeMode', value: _themeModeString(themeMode));
    notifyListeners();
  }

  void toggleTheme(String themeModes) {
    if (themeModes == 'Light Mode') {
      themeMode = ThemeMode.light;
    } else if (themeModes == 'Dark Mode') {
      themeMode = ThemeMode.dark;
    }
  }

  void setThemeSystem() {
    themeMode = ThemeMode.system;
  }

  String _themeModeString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
}
