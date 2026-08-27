import 'package:intl/intl.dart';

/// Cached NumberFormat / DateFormat instances per locale. Formatters
/// are non-trivial to construct — allocating them fresh in every
/// widget build() call on a list of 20 rows means 40+ allocations per
/// rebuild. Reuse them here instead.
class LocaleFormatters {
  static final Map<String, LocaleFormatters> _cache = {};

  final NumberFormat number;
  final NumberFormat number2;
  final DateFormat yMMMd;
  final DateFormat MMMd;
  final DateFormat E;
  final DateFormat Hm;

  LocaleFormatters._(String locale)
      : number = NumberFormat.decimalPattern(locale),
        number2 = NumberFormat.decimalPatternDigits(
            locale: locale, decimalDigits: 2),
        yMMMd = DateFormat.yMMMd(locale),
        MMMd = DateFormat.MMMd(locale),
        E = DateFormat.E(locale),
        Hm = DateFormat.Hm(locale);

  factory LocaleFormatters.of(String locale) =>
      _cache.putIfAbsent(locale, () => LocaleFormatters._(locale));
}
