import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:dinar_echange/services/cache_service.dart';

void main() {
  final cache = CacheManager();

  group('generateCacheKey', () {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    test('appends today\'s date with no suffix', () {
      expect(cache.generateCacheKey('rates'), 'rates_$today');
    });

    test('inserts the suffix before the date', () {
      expect(cache.generateCacheKey('rates', suffix: 'EUR'),
          'rates_EUR_$today');
    });
  });

  group('isDataNotEmpty', () {
    // These pin the behaviour after the strict-cast fix — the previous
    // implementation called `.isNotEmpty` on a `dynamic` value which fails
    // under strict-casts. The new form uses `is List && isNotEmpty`.

    test('true when data is a non-empty list', () {
      expect(cache.isDataNotEmpty({'data': [1, 2, 3]}), isTrue);
    });

    test('false when data is an empty list', () {
      expect(cache.isDataNotEmpty({'data': <dynamic>[]}), isFalse);
    });

    test('true when data is a map with a non-empty history list', () {
      expect(
          cache.isDataNotEmpty({
            'data': {
              'history': [
                {'date': '2024-01-01', 'buy': 1.0}
              ]
            }
          }),
          isTrue);
    });

    test('false when data is a map with an empty history list', () {
      expect(
          cache.isDataNotEmpty({
            'data': {'history': <dynamic>[]}
          }),
          isFalse);
    });

    test('false when data map is missing the history key', () {
      expect(cache.isDataNotEmpty({'data': <String, dynamic>{}}), isFalse);
    });

    test('false when there is no data key at all', () {
      expect(cache.isDataNotEmpty(<String, dynamic>{}), isFalse);
    });
  });

  group('isSameDay / isPreviousDay', () {
    final base = DateTime(2024, 6, 15);

    test('isSameDay matches on same day-of-month', () {
      expect(cache.isSameDay(base, DateTime(2024, 6, 15, 12)), isTrue);
    });

    test('isPreviousDay matches the day before', () {
      final yesterday = DateTime(2024, 6, 14, 8);
      expect(cache.isPreviousDay(yesterday, base), isTrue);
    });
  });
}
