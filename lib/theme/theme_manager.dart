import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeManager {
  static CardTheme currencyInputCardTheme(BuildContext context) {
    return CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5), // Rounded corners
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
      contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
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
        color: Theme.of(context).colorScheme.onSurface,
        height: 0.0);
  }

  static NavigationBarThemeData navigationBarTheme(ColorScheme colorScheme) {
    return NavigationBarThemeData(
      overlayColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed) ||
              states.contains(MaterialState.focused) ||
              states.contains(MaterialState.hovered)) {
            return Colors.transparent; 
          }
          return null; 
        },
      ),
      backgroundColor:
          colorScheme.background, // Background color from the color scheme
      indicatorColor: colorScheme.primary, // Primary color for the indicator
      labelTextStyle: MaterialStateProperty.all(
        TextStyle(
          fontSize: 14,
          color: colorScheme.onBackground, // Text color on the background
        ),
      ),
      iconTheme: MaterialStateProperty.all(
        IconThemeData(
          size: 24, // Icon size
        ),
      ),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
            2), // Subtle rounded corners for the indicator
      ),
      height: 56, // Height of the navigation bar
      labelBehavior: NavigationDestinationLabelBehavior
          .onlyShowSelected, // Show labels only for selected item
    );
  }

  static TextStyle appBarTextFieldStyle(ColorScheme colorScheme) {
    return TextStyle(
      color: colorScheme.onSecondaryContainer,
      fontSize: 16,
    );
  }

  static ThemeData baseTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          side: MaterialStateProperty.all(
            BorderSide(color: colorScheme.onSurface, width: 1.0),
          ),
          backgroundColor: MaterialStateProperty.all(colorScheme.background),
          foregroundColor: MaterialStateProperty.all(colorScheme.onBackground),
          textStyle: MaterialStateProperty.all(
            TextStyle(color: colorScheme.onBackground),
          ),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          ),
        ),
      ),
      navigationBarTheme: navigationBarTheme(colorScheme),
      scaffoldBackgroundColor: colorScheme.background,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      primaryColor: colorScheme.primary,
      textTheme: GoogleFonts.latoTextTheme().apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
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
              return colorScheme.secondary;
            }
            return colorScheme.onSurface.withOpacity(0.6);
          },
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: colorScheme.primary,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }
}
