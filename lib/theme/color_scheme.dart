import 'package:flutter/material.dart';
import 'package:dinar_watch/theme/theme_manager.dart';

class ColorSchemeManager {
  static final ThemeData darkTheme = ThemeManager.baseTheme(
    ColorScheme.fromSeed(
      seedColor: Colors.grey,
      brightness: Brightness.dark,
      primary: Colors.black,
      onPrimary: Colors.white,
      primaryContainer: Colors.black,
      onPrimaryContainer: Colors.white,
      secondary: Colors.white,
      secondaryContainer: Colors.white,
      onSecondary: Colors.black,
      surfaceTint: Colors.grey[850],
      surface: Colors.grey[850],
      background: Colors.black,
      error: Colors.red,
    ),
    Colors.white,
    Colors.white,
  );

  static final ThemeData lightTheme = ThemeManager.baseTheme(
    ColorScheme.fromSeed(
      seedColor: Colors.white,
      brightness: Brightness.light,
      primary: Colors.white,
      primaryContainer: Colors.white,
      secondary: Colors.black,
      secondaryContainer: Colors.black,
      surfaceTint: Colors.white,
      onSecondary: Colors.white,
      surface: Colors.grey[200],
      background: Colors.white,
      error: Colors.red,
    ),
    Colors.black,
    Colors.black,
  );
}
