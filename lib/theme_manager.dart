import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeManager {
  static ThemeData _baseTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      primaryColor: colorScheme.primary,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      textTheme: GoogleFonts.latoTextTheme(),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.onSurface, // Classy color for FAB
        foregroundColor: Colors.white, // For the icons/text inside FAB
      ),
      cardTheme: CardTheme(
        color: colorScheme.brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.white,
        elevation: 4,
        margin: const EdgeInsets.all(8),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        fillColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.lightGreen; // Greenish color for selected Checkbox
            }
            return colorScheme.onSurface.withOpacity(0.6); // Default color
          },
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: colorScheme.primary,
        textTheme: ButtonTextTheme.primary,
      ),
      // ... other widget themes ...
    );
  }

  static final darkTheme = _baseTheme(
    ColorScheme.fromSeed(seedColor: Colors.grey, brightness: Brightness.dark),
  );

  static final lightTheme = _baseTheme(
    ColorScheme.fromSeed(seedColor: Colors.white, brightness: Brightness.light),
  );
}
