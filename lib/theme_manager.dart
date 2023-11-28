import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeManager {
  static CardTheme currencyInputCardTheme(BuildContext context) {
    return CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Classy rounded corners
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      color: Theme.of(context).colorScheme.background,
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
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface, // Adapt to theme
    );
  }

  static ThemeData _baseTheme(
      ColorScheme colorScheme, Color bodyTextColor, Color displayTextColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme.copyWith(
        primary: colorScheme.brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
      primaryColor: colorScheme.primary,

      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
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
              return const Color.fromARGB(
                  255, 230, 255, 201); // Greenish color for selected Checkbox
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
      secondary: Colors.white,
      onSecondary: Colors.black,
    ),
    Colors.white, // White text for dark theme
    Colors.white, // White display text for dark theme
  );

  static final lightTheme = _baseTheme(
    ColorScheme.fromSeed(
      seedColor: Colors.white,
      brightness: Brightness.light,
      secondary: Colors.black,
      onSecondary: Colors.white,
    ),
    Colors.black, // Black text for light theme
    Colors.black, // Black display text for light theme
  );
}
