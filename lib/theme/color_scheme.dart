import 'package:flutter/material.dart';
import 'package:dinar_watch/theme/theme_manager.dart';

class ColorSchemeManager {
  static final ThemeData darkTheme = ThemeManager.baseTheme(
    ColorScheme.fromSeed(
      seedColor: Colors.grey,
      brightness: Brightness.dark,
      primary: Color(0xFF000000), // Black
      onPrimary: Color(0xFFFFFFFF), // White
      primaryContainer: Color(0xFF424242), // Dark Grey
      onPrimaryContainer: Color(0xFFF5F5F5), // Light Grey
      secondary: Color(0xFFF5F5F5), // Light Grey
      onSecondary: Color(0xFF000000), // Black
      secondaryContainer: Color(0xFF424242), // Dark Grey
      onSecondaryContainer: Color(0xFFFFFFFF), // White
      tertiary: Color(0xFF424242), // Dark Grey
      onTertiary: Color(0xFFFFFFFF), // White
      tertiaryContainer: Color(0xFFF5F5F5), // Light Grey
      onTertiaryContainer: Color(0xFF000000), // Black
      error: Color(0xFFF2B8B5), // Light Red
      onError: Color(0xFF601410), // Dark Red
      errorContainer: Color(0xFF8C1D18), // Dark Red
      onErrorContainer: Color(0xFFF9DEDC), // Light Red
      background: Color(0xFF000000), // Black
      onBackground: Color(0xFFF5F5F5), // Light Grey
      surface: Color(0xFF000000), // Black
      onSurface: Color(0xFFF5F5F5), // Light Grey
      surfaceVariant: Color(0xFF424242), // Dark Grey
      onSurfaceVariant: Color(0xFFF5F5F5), // Light Grey
      inverseSurface: Color(0xFFF5F5F5), // Light Grey
      onInverseSurface: Color(0xFF000000), // Black
      inversePrimary: Color(0xFFF5F5F5), // Light Grey
      shadow: Color(0xFF000000), // Black
      surfaceTint: Color(0xFF000000), // Black
      outline: Color(0xFFF5F5F5), // Light Grey
      outlineVariant: Color(0xFF424242), // Dark Grey
      scrim: Color(0xFF000000), // Black
    ),
  );

  static ThemeData lightTheme = ThemeManager.baseTheme(
    ColorScheme.fromSeed(
      seedColor: Colors.white,
      brightness: Brightness.light,
      primary: Color(0xFFFFFFFF), // White
      onPrimary: Color(0xFF000000), // Black
      primaryContainer: Color(0xFFE0E0E0), // Light Grey
      onPrimaryContainer: Color(0xFF000000), // Black
      secondary: Color(0xFF000000), // Black
      onSecondary: Color(0xFFFFFFFF), // White
      secondaryContainer: Color(0xFFE0E0E0), // Light Grey
      onSecondaryContainer: Color(0xFF000000), // Black
      tertiary: Color(0xFFE0E0E0), // Light Grey
      onTertiary: Color(0xFF000000), // Black
      tertiaryContainer: Color(0xFF000000), // Black
      onTertiaryContainer: Color(0xFFFFFFFF), // White
      error: Color(0xFFB3261E), // Red
      onError: Color(0xFFFFFFFF), // White
      errorContainer: Color(0xFFF9DEDC), // Light Red
      onErrorContainer: Color(0xFF410E0B), // Dark Red
      background: Color(0xFFFFFFFF), // White
      onBackground: Color(0xFF000000), // Black
      surface: Color(0xFFFFFFFF), // White
      onSurface: Color(0xFF000000), // Black
      surfaceVariant: Color(0xFFE0E0E0), // Light Grey
      onSurfaceVariant: Color(0xFF000000), // Black
      inverseSurface: Color(0xFF000000), // Black
      onInverseSurface: Color(0xFFFFFFFF), // White
      inversePrimary: Color(0xFF000000), // Black
      shadow: Color(0xFF000000), // Black
      surfaceTint: Color(0xFFFFFFFF), // White
      outline: Color(0xFF000000), // Black
      outlineVariant: Color(0xFF000000), // Black
      scrim: Color(0xFF000000), // Black
    ),
  );
}
