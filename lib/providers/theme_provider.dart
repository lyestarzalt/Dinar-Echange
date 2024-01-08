import 'package:flutter/material.dart';
import 'package:dinar_watch/shared/enums.dart';
import 'package:dinar_watch/services/preferences_service.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    loadThemeMode();
  }

  void setThemeMode(ThemeOption option) async {
    switch (option) {
      case ThemeOption.dark:
        _themeMode = ThemeMode.dark;
        break;
      case ThemeOption.light:
        _themeMode = ThemeMode.light;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
    await PreferencesService().setThemeMode(option);
    notifyListeners();
  }

  Future<void> loadThemeMode() async {
    _themeMode = await PreferencesService().getThemeMode();
    notifyListeners();
  }
}
