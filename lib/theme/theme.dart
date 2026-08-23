import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dinar_echange/theme/brand_colors.dart';

/// Dinar Echange design system.
///
/// Palette grounded in Algerian material culture (Casbah roofs, dinar
/// coins, aged parchment). Two domain colors — sage for the government
/// rate and casbah for the parallel/souq rate — carry meaning rather
/// than decorating. Brass ties them together as the spread accent.
class MaterialTheme {
  // -- Raw palette ---------------------------------------------------------
  static const _paper = Color(0xFFEEEADF); // cool parchment — grayer than AI cream
  static const _ink = Color(0xFF161311); // warm near-black
  static const _sage = Color(0xFF33513E); // official rate
  static const _casbah = Color(0xFF8B3A2A); // parallel/souq rate
  static const _brass = Color(0xFFA8843A); // spread, positive delta
  static const _sand = Color(0xFF6E6558); // secondary text, hairlines
  // Dark counterparts.
  static const _night = Color(0xFF17140F); // deep warm brown
  static const _sageDark = Color(0xFF7FA48A);
  static const _casbahDark = Color(0xFFD09B87);
  static const _brassDark = Color(0xFFCAA867);
  static const _sandDark = Color(0xFFA69C90);

  ThemeData light() => _build(Brightness.light, contrast: false);
  ThemeData dark() => _build(Brightness.dark, contrast: false);
  ThemeData lightHighContrast() => _build(Brightness.light, contrast: true);
  ThemeData darkHighContrast() => _build(Brightness.dark, contrast: true);

  ThemeData _build(Brightness brightness, {required bool contrast}) {
    final isDark = brightness == Brightness.dark;
    final paper = isDark ? _night : _paper;
    final ink = isDark ? _paper : _ink;
    final sage = isDark ? _sageDark : _sage;
    final casbah = isDark ? _casbahDark : _casbah;
    final brass = isDark ? _brassDark : _brass;
    final sand = isDark ? _sandDark : _sand;

    final scheme = ColorScheme.fromSeed(
      seedColor: sage,
      brightness: brightness,
    ).copyWith(
      // Primary is ink, not sage — the app's default control color is
      // near-black so buttons don't turn every screen green. Sage stays
      // as the semantic "official market" tint via BrandColors.
      primary: ink,
      onPrimary: paper,
      secondary: sage,
      onSecondary: paper,
      tertiary: brass,
      onTertiary: paper,
      surface: paper,
      onSurface: ink,
      onSurfaceVariant: sand,
      outlineVariant: contrast
          ? sand.withValues(alpha: 0.6)
          : sand.withValues(alpha: 0.25),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: paper,
      canvasColor: paper,
      textTheme: _textTheme(scheme),
      extensions: [
        BrandColors(
          official: sage,
          parallel: casbah,
          spread: brass,
          paperInk: ink.withValues(alpha: 0.62),
        ),
      ],

      // Platform-native transitions (Cupertino swipe-back on iOS).
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      appBarTheme: AppBarTheme(
        toolbarHeight: Platform.isIOS ? 44 : 56,
        centerTitle: Platform.isIOS,
        backgroundColor: paper,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.bricolageGrotesque(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ink,
          letterSpacing: -0.2,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: paper,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: sand.withValues(alpha: 0.2), width: 1),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: sand.withValues(alpha: 0.25)),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        contentTextStyle: GoogleFonts.instrumentSans(color: paper, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: paper,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.instrumentSans(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: BorderSide(color: sand.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.instrumentSans(fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ink,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          textStyle: GoogleFonts.instrumentSans(fontWeight: FontWeight.w500),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: sand.withValues(alpha: 0.08),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ink, width: 1.5),
        ),
      ),

      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide(color: sand.withValues(alpha: 0.4)),
        backgroundColor: paper,
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          ),
        ),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: ink,
        unselectedLabelColor: sand,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: ink, width: 2),
          insets: const EdgeInsets.symmetric(horizontal: 4),
        ),
        labelStyle: GoogleFonts.instrumentSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.6,
        ),
        unselectedLabelStyle: GoogleFonts.instrumentSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.6,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: paper,
        indicatorColor: sage.withValues(alpha: 0.14),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.instrumentSans(fontSize: 11, color: ink),
        ),
        iconTheme: WidgetStateProperty.all(
          IconThemeData(size: 22, color: ink),
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.selected) ? ink : paper,
        ),
        checkColor: WidgetStateProperty.all(paper),
        side: BorderSide(color: sand.withValues(alpha: 0.5)),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: brass,
        linearTrackColor: sand.withValues(alpha: 0.15),
        circularTrackColor: sand.withValues(alpha: 0.15),
      ),

      dividerTheme: DividerThemeData(
        color: sand.withValues(alpha: 0.18),
        thickness: 1,
        space: 1,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ink,
        foregroundColor: paper,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    const tabular = <FontFeature>[FontFeature.tabularFigures()];

    // Bricolage Grotesque carries display personality — the variable
    // width gives titles a hand-set feel without going full serif.
    // Instrument Sans is the quiet workhorse for UI and body.
    TextStyle display({
      required double size,
      FontWeight weight = FontWeight.w500,
      double letterSpacing = -0.5,
      double height = 1.0,
      List<FontFeature>? features,
    }) =>
        GoogleFonts.bricolageGrotesque(
          fontSize: size,
          fontWeight: weight,
          letterSpacing: letterSpacing,
          height: height,
          color: scheme.onSurface,
          fontFeatures: features,
        );

    TextStyle body({
      required double size,
      FontWeight weight = FontWeight.w400,
      double letterSpacing = 0,
      double? height,
      List<FontFeature>? features,
      Color? color,
    }) =>
        GoogleFonts.instrumentSans(
          fontSize: size,
          fontWeight: weight,
          letterSpacing: letterSpacing,
          height: height,
          color: color ?? scheme.onSurface,
          fontFeatures: features,
        );

    return TextTheme(
      // Hero rate on the featured card. Bricolage at heavy weight with
      // negative tracking so the digits feel confident and set.
      displayLarge: display(
        size: 64,
        weight: FontWeight.w700,
        letterSpacing: -2.5,
        features: tabular,
      ),
      displayMedium: display(size: 40, weight: FontWeight.w600, letterSpacing: -1.5),
      // Row rate values.
      displaySmall: body(
        size: 24,
        weight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.0,
        features: tabular,
      ),
      headlineMedium: display(size: 22, weight: FontWeight.w600, letterSpacing: -0.6),
      // Currency codes and section titles.
      titleLarge: body(size: 18, weight: FontWeight.w600, letterSpacing: -0.2),
      titleMedium: body(size: 15, weight: FontWeight.w600),
      bodyLarge: body(size: 15, height: 1.4),
      bodyMedium: body(size: 14, height: 1.4),
      // Tags: PARALLEL / OFFICIAL / BUY / SELL — tight tracking, small.
      labelSmall: body(
        size: 10,
        weight: FontWeight.w700,
        letterSpacing: 1.6,
        color: scheme.onSurfaceVariant,
      ),
      labelMedium: body(
        size: 12,
        weight: FontWeight.w500,
        letterSpacing: 0.4,
        color: scheme.onSurfaceVariant,
      ),
    );
  }

  MaterialTheme();
}
