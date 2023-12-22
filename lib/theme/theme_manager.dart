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

  static NavigationBarThemeData navigationBarTheme(ColorScheme colorScheme) {
    return NavigationBarThemeData(
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
          color: colorScheme.onBackground
              .withOpacity(0.6), // Slightly transparent icons
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

  static ThemeData baseTheme(
      ColorScheme colorScheme, Color bodyTextColor, Color displayTextColor) {
    return ThemeData(
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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
            const EdgeInsets.symmetric(
                horizontal: 20.0, vertical: 10.0), // Adjust for size
          ),
        ),
      ),

      navigationBarTheme: navigationBarTheme(colorScheme),
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
              return const Color.fromARGB(255, 43, 255, 0);
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
