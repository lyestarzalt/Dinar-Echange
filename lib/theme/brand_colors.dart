import 'package:flutter/material.dart';

/// Colors that carry domain meaning specific to the dinar economy and
/// don't map onto Material's neutral ColorScheme roles.
///
/// Read via `Theme.of(context).extension<BrandColors>()!`.
@immutable
class BrandColors extends ThemeExtension<BrandColors> {
  /// Government-published rate. Sage — deep, considered, institutional.
  final Color official;

  /// Parallel/souq rate. Casbah roof-tile terra-cotta — grounded,
  /// warm, distinctly Algerian.
  final Color parallel;

  /// The gap between markets, positive deltas, refresh accents.
  /// Aged dinar-coin brass.
  final Color spread;

  /// Ink on paper at reduced weight — for secondary UI where
  /// onSurfaceVariant is too gray to feel intentional.
  final Color paperInk;

  const BrandColors({
    required this.official,
    required this.parallel,
    required this.spread,
    required this.paperInk,
  });

  @override
  BrandColors copyWith({
    Color? official,
    Color? parallel,
    Color? spread,
    Color? paperInk,
  }) {
    return BrandColors(
      official: official ?? this.official,
      parallel: parallel ?? this.parallel,
      spread: spread ?? this.spread,
      paperInk: paperInk ?? this.paperInk,
    );
  }

  @override
  BrandColors lerp(covariant BrandColors? other, double t) {
    if (other == null) return this;
    return BrandColors(
      official: Color.lerp(official, other.official, t)!,
      parallel: Color.lerp(parallel, other.parallel, t)!,
      spread: Color.lerp(spread, other.spread, t)!,
      paperInk: Color.lerp(paperInk, other.paperInk, t)!,
    );
  }
}

extension BrandColorsX on BuildContext {
  BrandColors get brand => Theme.of(this).extension<BrandColors>()!;
}
