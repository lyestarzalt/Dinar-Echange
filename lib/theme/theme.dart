import "package:flutter/material.dart";
import 'package:dinar_watch/theme/material_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

class MaterialTheme {
  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: _createCustomTextTheme(
            colorScheme.brightness == Brightness.light
                ? ThemeData.light().textTheme
                : ThemeData.dark().textTheme),
        scaffoldBackgroundColor: colorScheme.background,
        canvasColor: colorScheme.surface,
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            side: MaterialStateProperty.all(
              BorderSide(color: colorScheme.onSurface, width: 1.0),
            ),
            backgroundColor: MaterialStateProperty.all(colorScheme.background),
            foregroundColor:
                MaterialStateProperty.all(colorScheme.onBackground),
            textStyle: MaterialStateProperty.all(
              TextStyle(color: colorScheme.onBackground),
            ),
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(toolbarHeight: 80),
        navigationBarTheme: NavigationBarThemeData(
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
          indicatorColor:
              colorScheme.primary, // Primary color for the indicator
          labelTextStyle: MaterialStateProperty.all(
            TextStyle(
              fontSize: 14,
              color: colorScheme.onBackground, // Text color on the background
            ),
          ),
          iconTheme: MaterialStateProperty.all(
            const IconThemeData(
              size: 24, // Icon size
            ),
          ),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
          height: 56,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
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
      );
  static TextTheme _createCustomTextTheme(TextTheme base) {
    return GoogleFonts.robotoMonoTextTheme(base);
  }

  MaterialTheme();

  static MaterialScheme lightScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(0xff4c662b),
      surfaceTint: Color(0xff4c662b),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffcdeda3),
      onPrimaryContainer: Color(0xff102000),
      secondary: Color(0xff586249),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffdce7c8),
      onSecondaryContainer: Color(0xff151e0b),
      tertiary: Color(0xff386663),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffbcece7),
      onTertiaryContainer: Color(0xff00201e),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff410002),
      background: Color(0xfff9faef),
      onBackground: Color(0xff1a1c16),
      surface: Color(0xfff9faef),
      onSurface: Color(0xff1a1c16),
      surfaceVariant: Color(0xffe1e4d5),
      onSurfaceVariant: Color(0xff44483d),
      outline: Color(0xff75796c),
      outlineVariant: Color(0xffc5c8ba),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f312a),
      inverseOnSurface: Color(0xfff1f2e6),
      inversePrimary: Color(0xffb1d18a),
      primaryFixed: Color(0xffcdeda3),
      onPrimaryFixed: Color(0xff102000),
      primaryFixedDim: Color(0xffb1d18a),
      onPrimaryFixedVariant: Color(0xff354e16),
      secondaryFixed: Color(0xffdce7c8),
      onSecondaryFixed: Color(0xff151e0b),
      secondaryFixedDim: Color(0xffbfcbad),
      onSecondaryFixedVariant: Color(0xff404a33),
      tertiaryFixed: Color(0xffbcece7),
      onTertiaryFixed: Color(0xff00201e),
      tertiaryFixedDim: Color(0xffa0d0cb),
      onTertiaryFixedVariant: Color(0xff1f4e4b),
      surfaceDim: Color(0xffdadbd0),
      surfaceBright: Color(0xfff9faef),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f4e9),
      surfaceContainer: Color(0xffeeefe3),
      surfaceContainerHigh: Color(0xffe8e9de),
      surfaceContainerHighest: Color(0xffe2e3d8),
    );
  }

  ThemeData light() {
    return theme(lightScheme().toColorScheme());
  }

  static MaterialScheme lightMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(0xff314a12),
      surfaceTint: Color(0xff4c662b),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff617d3f),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff3c462f),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff6e785e),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff1a4a47),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff4f7d79),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff8c0009),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffda342e),
      onErrorContainer: Color(0xffffffff),
      background: Color(0xfff9faef),
      onBackground: Color(0xff1a1c16),
      surface: Color(0xfff9faef),
      onSurface: Color(0xff1a1c16),
      surfaceVariant: Color(0xffe1e4d5),
      onSurfaceVariant: Color(0xff404439),
      outline: Color(0xff5d6155),
      outlineVariant: Color(0xff787c70),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f312a),
      inverseOnSurface: Color(0xfff1f2e6),
      inversePrimary: Color(0xffb1d18a),
      primaryFixed: Color(0xff617d3f),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff496429),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff6e785e),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff555f47),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff4f7d79),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff366460),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffdadbd0),
      surfaceBright: Color(0xfff9faef),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f4e9),
      surfaceContainer: Color(0xffeeefe3),
      surfaceContainerHigh: Color(0xffe8e9de),
      surfaceContainerHighest: Color(0xffe2e3d8),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme lightHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(0xff142700),
      surfaceTint: Color(0xff4c662b),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff314a12),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff1c2511),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff3c462f),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff002725),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff1a4a47),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff4e0002),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff8c0009),
      onErrorContainer: Color(0xffffffff),
      background: Color(0xfff9faef),
      onBackground: Color(0xff1a1c16),
      surface: Color(0xfff9faef),
      onSurface: Color(0xff000000),
      surfaceVariant: Color(0xffe1e4d5),
      onSurfaceVariant: Color(0xff21251c),
      outline: Color(0xff404439),
      outlineVariant: Color(0xff404439),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f312a),
      inverseOnSurface: Color(0xffffffff),
      inversePrimary: Color(0xffd6f7ac),
      primaryFixed: Color(0xff314a12),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff1c3300),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff3c462f),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff26301b),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff1a4a47),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff003331),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffdadbd0),
      surfaceBright: Color(0xfff9faef),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f4e9),
      surfaceContainer: Color(0xffeeefe3),
      surfaceContainerHigh: Color(0xffe8e9de),
      surfaceContainerHighest: Color(0xffe2e3d8),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme().toColorScheme());
  }

  static MaterialScheme darkScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(0xffb1d18a),
      surfaceTint: Color(0xffb1d18a),
      onPrimary: Color(0xff1f3701),
      primaryContainer: Color(0xff354e16),
      onPrimaryContainer: Color(0xffcdeda3),
      secondary: Color(0xffbfcbad),
      onSecondary: Color(0xff2a331e),
      secondaryContainer: Color(0xff404a33),
      onSecondaryContainer: Color(0xffdce7c8),
      tertiary: Color(0xffa0d0cb),
      onTertiary: Color(0xff003735),
      tertiaryContainer: Color(0xff1f4e4b),
      onTertiaryContainer: Color(0xffbcece7),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      background: Color(0xff12140e),
      onBackground: Color(0xffe2e3d8),
      surface: Color(0xff12140e),
      onSurface: Color(0xffe2e3d8),
      surfaceVariant: Color(0xff44483d),
      onSurfaceVariant: Color(0xffc5c8ba),
      outline: Color(0xff8f9285),
      outlineVariant: Color(0xff44483d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e3d8),
      inverseOnSurface: Color(0xff2f312a),
      inversePrimary: Color(0xff4c662b),
      primaryFixed: Color(0xffcdeda3),
      onPrimaryFixed: Color(0xff102000),
      primaryFixedDim: Color(0xffb1d18a),
      onPrimaryFixedVariant: Color(0xff354e16),
      secondaryFixed: Color(0xffdce7c8),
      onSecondaryFixed: Color(0xff151e0b),
      secondaryFixedDim: Color(0xffbfcbad),
      onSecondaryFixedVariant: Color(0xff404a33),
      tertiaryFixed: Color(0xffbcece7),
      onTertiaryFixed: Color(0xff00201e),
      tertiaryFixedDim: Color(0xffa0d0cb),
      onTertiaryFixedVariant: Color(0xff1f4e4b),
      surfaceDim: Color(0xff12140e),
      surfaceBright: Color(0xff383a32),
      surfaceContainerLowest: Color(0xff0c0f09),
      surfaceContainerLow: Color(0xff1a1c16),
      surfaceContainer: Color(0xff1e201a),
      surfaceContainerHigh: Color(0xff282b24),
      surfaceContainerHighest: Color(0xff33362e),
    );
  }

  ThemeData dark() {
    return theme(darkScheme().toColorScheme());
  }

  static MaterialScheme darkMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(0xffb5d58e),
      surfaceTint: Color(0xffb1d18a),
      onPrimary: Color(0xff0c1a00),
      primaryContainer: Color(0xff7d9a59),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffc4cfb1),
      onSecondary: Color(0xff101907),
      secondaryContainer: Color(0xff8a9579),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffa4d4d0),
      onTertiary: Color(0xff001a19),
      tertiaryContainer: Color(0xff6b9995),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffbab1),
      onError: Color(0xff370001),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      background: Color(0xff12140e),
      onBackground: Color(0xffe2e3d8),
      surface: Color(0xff12140e),
      onSurface: Color(0xfffbfcf0),
      surfaceVariant: Color(0xff44483d),
      onSurfaceVariant: Color(0xffc9ccbe),
      outline: Color(0xffa1a497),
      outlineVariant: Color(0xff818578),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e3d8),
      inverseOnSurface: Color(0xff282b24),
      inversePrimary: Color(0xff364f17),
      primaryFixed: Color(0xffcdeda3),
      onPrimaryFixed: Color(0xff081400),
      primaryFixedDim: Color(0xffb1d18a),
      onPrimaryFixedVariant: Color(0xff253d05),
      secondaryFixed: Color(0xffdce7c8),
      onSecondaryFixed: Color(0xff0b1403),
      secondaryFixedDim: Color(0xffbfcbad),
      onSecondaryFixedVariant: Color(0xff303924),
      tertiaryFixed: Color(0xffbcece7),
      onTertiaryFixed: Color(0xff001413),
      tertiaryFixedDim: Color(0xffa0d0cb),
      onTertiaryFixedVariant: Color(0xff083d3a),
      surfaceDim: Color(0xff12140e),
      surfaceBright: Color(0xff383a32),
      surfaceContainerLowest: Color(0xff0c0f09),
      surfaceContainerLow: Color(0xff1a1c16),
      surfaceContainer: Color(0xff1e201a),
      surfaceContainerHigh: Color(0xff282b24),
      surfaceContainerHighest: Color(0xff33362e),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme darkHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff4ffdf),
      surfaceTint: Color(0xffb1d18a),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffb5d58e),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xfff4ffdf),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffc4cfb1),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffeafffc),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffa4d4d0),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xfffff9f9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffbab1),
      onErrorContainer: Color(0xff000000),
      background: Color(0xff12140e),
      onBackground: Color(0xffe2e3d8),
      surface: Color(0xff12140e),
      onSurface: Color(0xffffffff),
      surfaceVariant: Color(0xff44483d),
      onSurfaceVariant: Color(0xfff9fced),
      outline: Color(0xffc9ccbe),
      outlineVariant: Color(0xffc9ccbe),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e3d8),
      inverseOnSurface: Color(0xff000000),
      inversePrimary: Color(0xff1a3000),
      primaryFixed: Color(0xffd1f2a7),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffb5d58e),
      onPrimaryFixedVariant: Color(0xff0c1a00),
      secondaryFixed: Color(0xffe0ebcc),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffc4cfb1),
      onSecondaryFixedVariant: Color(0xff101907),
      tertiaryFixed: Color(0xffc0f0ec),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffa4d4d0),
      onTertiaryFixedVariant: Color(0xff001a19),
      surfaceDim: Color(0xff12140e),
      surfaceBright: Color(0xff383a32),
      surfaceContainerLowest: Color(0xff0c0f09),
      surfaceContainerLow: Color(0xff1a1c16),
      surfaceContainer: Color(0xff1e201a),
      surfaceContainerHigh: Color(0xff282b24),
      surfaceContainerHighest: Color(0xff33362e),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme().toColorScheme());
  }
}

extension MaterialSchemeUtils on MaterialScheme {
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      background: background,
      onBackground: onBackground,
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
    );
  }
}
