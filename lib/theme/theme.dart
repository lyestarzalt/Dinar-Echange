import "package:flutter/material.dart";
import 'package:dinar_watch/theme/material_scheme.dart';

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
        appBarTheme: const AppBarTheme(toolbarHeight: 90),
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.all(
            TextStyle(
              fontSize: 14,
              color: colorScheme.onBackground,
            ),
          ),
          iconTheme: MaterialStateProperty.all(
            const IconThemeData(
              size: 24,
            ),
          ),
          height: 70,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
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
    return base.apply(fontFamily: 'UbuntuMono');
  }

  MaterialTheme();
  static MaterialScheme lightScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4282411062),
      surfaceTint: Color(4282411062),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4290834352),
      onPrimaryContainer: Color(4278198784),
      secondary: Color(4283720525),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4292339917),
      onSecondaryContainer: Color(4279377678),
      tertiary: Color(4281886056),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4290571246),
      onTertiaryContainer: Color(4278198306),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      background: Color(4294507505),
      onBackground: Color(4279835927),
      surface: Color(4294507505),
      onSurface: Color(4279835927),
      surfaceVariant: Color(4292863191),
      onSurfaceVariant: Color(4282599487),
      outline: Color(4285757806),
      outlineVariant: Color(4291020988),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281217579),
      inverseOnSurface: Color(4293915368),
      inversePrimary: Color(4289057686),
      primaryFixed: Color(4290834352),
      onPrimaryFixed: Color(4278198784),
      primaryFixedDim: Color(4289057686),
      onPrimaryFixedVariant: Color(4280832032),
      secondaryFixed: Color(4292339917),
      onSecondaryFixed: Color(4279377678),
      secondaryFixedDim: Color(4290497458),
      onSecondaryFixedVariant: Color(4282141495),
      tertiaryFixed: Color(4290571246),
      onTertiaryFixed: Color(4278198306),
      tertiaryFixedDim: Color(4288729042),
      onTertiaryFixedVariant: Color(4280175952),
      surfaceDim: Color(4292402130),
      surfaceBright: Color(4294507505),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294112747),
      surfaceContainer: Color(4293717989),
      surfaceContainerHigh: Color(4293323232),
      surfaceContainerHighest: Color(4292994266),
    );
  }

  ThemeData light() {
    return theme(lightScheme().toColorScheme());
  }

  static MaterialScheme lightMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4280568605),
      surfaceTint: Color(4282411062),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4283793226),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4281943859),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4285167971),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4279847244),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4283399295),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      background: Color(4294507505),
      onBackground: Color(4279835927),
      surface: Color(4294507505),
      onSurface: Color(4279835927),
      surfaceVariant: Color(4292863191),
      onSurfaceVariant: Color(4282336571),
      outline: Color(4284178775),
      outlineVariant: Color(4286020978),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281217579),
      inverseOnSurface: Color(4293915368),
      inversePrimary: Color(4289057686),
      primaryFixed: Color(4283793226),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4282213940),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4285167971),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4283523147),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4283399295),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4281754470),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292402130),
      surfaceBright: Color(4294507505),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294112747),
      surfaceContainer: Color(4293717989),
      surfaceContainerHigh: Color(4293323232),
      surfaceContainerHighest: Color(4292994266),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme lightHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4278331649),
      surfaceTint: Color(4282411062),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4280568605),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4279772692),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4281943859),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4278200105),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4279847244),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      background: Color(4294507505),
      onBackground: Color(4279835927),
      surface: Color(4294507505),
      onSurface: Color(4278190080),
      surfaceVariant: Color(4292863191),
      onSurfaceVariant: Color(4280296733),
      outline: Color(4282336571),
      outlineVariant: Color(4282336571),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281217579),
      inverseOnSurface: Color(4294967295),
      inversePrimary: Color(4291492281),
      primaryFixed: Color(4280568605),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4279055368),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4281943859),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4280496158),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4279847244),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4278202933),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292402130),
      surfaceBright: Color(4294507505),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294112747),
      surfaceContainer: Color(4293717989),
      surfaceContainerHigh: Color(4293323232),
      surfaceContainerHighest: Color(4292994266),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme().toColorScheme());
  }

  static MaterialScheme darkScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4289057686),
      surfaceTint: Color(4289057686),
      onPrimary: Color(4279318539),
      primaryContainer: Color(4280832032),
      onPrimaryContainer: Color(4290834352),
      secondary: Color(4290497458),
      onSecondary: Color(4280693794),
      secondaryContainer: Color(4282141495),
      onSecondaryContainer: Color(4292339917),
      tertiary: Color(4288729042),
      onTertiary: Color(4278204217),
      tertiaryContainer: Color(4280175952),
      onTertiaryContainer: Color(4290571246),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      background: Color(4279309327),
      onBackground: Color(4292994266),
      surface: Color(4279309327),
      onSurface: Color(4292994266),
      surfaceVariant: Color(4282599487),
      onSurfaceVariant: Color(4291020988),
      outline: Color(4287468423),
      outlineVariant: Color(4282599487),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292994266),
      inverseOnSurface: Color(4281217579),
      inversePrimary: Color(4282411062),
      primaryFixed: Color(4290834352),
      onPrimaryFixed: Color(4278198784),
      primaryFixedDim: Color(4289057686),
      onPrimaryFixedVariant: Color(4280832032),
      secondaryFixed: Color(4292339917),
      onSecondaryFixed: Color(4279377678),
      secondaryFixedDim: Color(4290497458),
      onSecondaryFixedVariant: Color(4282141495),
      tertiaryFixed: Color(4290571246),
      onTertiaryFixed: Color(4278198306),
      tertiaryFixedDim: Color(4288729042),
      onTertiaryFixedVariant: Color(4280175952),
      surfaceDim: Color(4279309327),
      surfaceBright: Color(4281743924),
      surfaceContainerLowest: Color(4278980362),
      surfaceContainerLow: Color(4279835927),
      surfaceContainer: Color(4280099099),
      surfaceContainerHigh: Color(4280757029),
      surfaceContainerHighest: Color(4281480751),
    );
  }

  ThemeData dark() {
    return theme(darkScheme().toColorScheme());
  }

  static MaterialScheme darkMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4289320857),
      surfaceTint: Color(4289057686),
      onPrimary: Color(4278197248),
      primaryContainer: Color(4285635684),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4290760886),
      onSecondary: Color(4279048457),
      secondaryContainer: Color(4287010174),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4288992214),
      onTertiary: Color(4278196763),
      tertiaryContainer: Color(4285241499),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949553),
      onError: Color(4281794561),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      background: Color(4279309327),
      onBackground: Color(4292994266),
      surface: Color(4279309327),
      onSurface: Color(4294573298),
      surfaceVariant: Color(4282599487),
      onSurfaceVariant: Color(4291284416),
      outline: Color(4288652697),
      outlineVariant: Color(4286547322),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292994266),
      inverseOnSurface: Color(4280757029),
      inversePrimary: Color(4280963361),
      primaryFixed: Color(4290834352),
      onPrimaryFixed: Color(4278195712),
      primaryFixedDim: Color(4289057686),
      onPrimaryFixedVariant: Color(4279713297),
      secondaryFixed: Color(4292339917),
      onSecondaryFixed: Color(4278719493),
      secondaryFixedDim: Color(4290497458),
      onSecondaryFixedVariant: Color(4281088551),
      tertiaryFixed: Color(4290571246),
      onTertiaryFixed: Color(4278195222),
      tertiaryFixedDim: Color(4288729042),
      onTertiaryFixedVariant: Color(4278664511),
      surfaceDim: Color(4279309327),
      surfaceBright: Color(4281743924),
      surfaceContainerLowest: Color(4278980362),
      surfaceContainerLow: Color(4279835927),
      surfaceContainer: Color(4280099099),
      surfaceContainerHigh: Color(4280757029),
      surfaceContainerHighest: Color(4281480751),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme darkHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4294115303),
      surfaceTint: Color(4289057686),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4289320857),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294115303),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4290760886),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4293721855),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4288992214),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      background: Color(4279309327),
      onBackground: Color(4292994266),
      surface: Color(4279309327),
      onSurface: Color(4294967295),
      surfaceVariant: Color(4282599487),
      onSurfaceVariant: Color(4294442479),
      outline: Color(4291284416),
      outlineVariant: Color(4291284416),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292994266),
      inverseOnSurface: Color(4278190080),
      inversePrimary: Color(4278857990),
      primaryFixed: Color(4291163316),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4289320857),
      onPrimaryFixedVariant: Color(4278197248),
      secondaryFixed: Color(4292603089),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4290760886),
      onSecondaryFixedVariant: Color(4279048457),
      tertiaryFixed: Color(4290834419),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4288992214),
      onTertiaryFixedVariant: Color(4278196763),
      surfaceDim: Color(4279309327),
      surfaceBright: Color(4281743924),
      surfaceContainerLowest: Color(4278980362),
      surfaceContainerLow: Color(4279835927),
      surfaceContainer: Color(4280099099),
      surfaceContainerHigh: Color(4280757029),
      surfaceContainerHighest: Color(4281480751),
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
