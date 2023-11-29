import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeManager {
  static CardTheme currencyInputCardTheme(BuildContext context) {
    return CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5), // Rounded corners
        // Default border settings
        side: BorderSide(
          color: Colors.grey.withOpacity(0.3), // Neutral border color
          width: 1.0,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      color: Theme.of(context).colorScheme.background,
      surfaceTintColor: Theme.of(context).colorScheme.background,
    );
  }

  static InputDecoration currencyInputDecoration(
      BuildContext context, String labelText) {
    return InputDecoration(
      labelText: labelText.toUpperCase(),
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16, // Set your desired font size for input text
      ),
      // Define the style for the label text
      hintStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16,
      ),
      border: InputBorder.none,
      // Additional styling as required
    );
  }

  static TextStyle moneyNumberStyle(BuildContext context) {
    return TextStyle(
      fontFamily: 'Courier',
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle currencyCodeStyle(BuildContext context) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface, // Adapt to theme
    );
  }

  static ThemeData _baseTheme(
      ColorScheme colorScheme, Color bodyTextColor, Color displayTextColor) {
    return ThemeData(
      scaffoldBackgroundColor: colorScheme.background,
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      primaryColor: colorScheme.primary,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary, // Background color of AppBar
        foregroundColor: colorScheme.brightness == Brightness.light
            ? Colors.black // Dark text for light theme AppBar
            : Colors.white, // Light text for dark theme AppBar
        elevation: 0,
      ),
      textTheme: GoogleFonts.latoTextTheme().apply(
        bodyColor: bodyTextColor,
        displayColor: displayTextColor,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      ),

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        fillColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Color.fromARGB(
                  255, 43, 255, 0); // Greenish color for selected Checkbox
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
    ColorScheme.fromSeed(
      seedColor: Colors.grey,
      brightness: Brightness.dark,
      primary: Colors.black, // Explicitly set the primary color for dark theme
      primaryContainer: Colors.black, // Consider setting this if needed
      secondary: Colors.white,
      secondaryContainer: Colors.white, // Adjust if needed
      onSecondary: Colors.black,
      surfaceTint: Colors.grey[850],
      surface: Colors
          .grey[850], // Or another appropriate color for dark theme surfaces
      background:
          Colors.grey[900], // Or another appropriate dark color for backgrounds
      error: Colors.red, // Adjust error color as needed
      // ... define other colors as needed ...
    ),
    Colors.white, // White text for dark theme
    Colors.white, // White display text for dark theme
  );

  static final lightTheme = _baseTheme(
    ColorScheme.fromSeed(
      seedColor: Colors.white,
      brightness: Brightness.light,
      primary: Colors.white, // Explicitly set the primary color for light theme
      primaryContainer: Colors.white, // Consider setting this if needed
      secondary: Colors.black,
      secondaryContainer: Colors.black, // Adjust if needed
      surfaceTint: Colors.white,
      onSecondary: Colors.white,
      surface:
          Colors.grey[200], // Or another appropriate light color for surfaces
      background: Colors.white, // Background color for the light theme
      error: Colors.red, // Adjust error color as needed
    ),
    Colors.black, // Black text for light theme
    Colors.black, // Black display text for light theme
  );
}
