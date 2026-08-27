import 'package:dinar_echange/data/services/firestore_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirestoreService.parseCurrencies', () {
    test('parses the full document shape into Currency objects', () {
      final currencies = FirestoreService.parseCurrencies(
        snapshotDate: '2025-11-04',
        ratesData: {
          'eur': {
            'buy': 232.0,
            'sell': 234.5,
            'is_core': true,
            'name': 'Euro',
            'symbol': '€',
            'flag': 'https://example.com/eu.png',
          },
          'usd': {
            'buy': 210.0,
            'sell': 213.0,
            'is_core': true,
          },
        },
      );

      expect(currencies, hasLength(2));

      final eur = currencies.firstWhere((c) => c.currencyCode == 'EUR');
      expect(eur.buy, 232.0);
      expect(eur.sell, 234.5);
      expect(eur.isCore, isTrue);
      expect(eur.currencyName, 'Euro');
      expect(eur.currencySymbol, '€');
      expect(eur.flag, 'https://example.com/eu.png');
      expect(eur.date, DateTime.parse('2025-11-04'));
    });

    test('uppercases the currency code taken from the map key', () {
      final currencies = FirestoreService.parseCurrencies(
        snapshotDate: '2025-01-01',
        ratesData: {
          'jpy': {'buy': 1.5, 'sell': 1.6, 'is_core': false},
        },
      );

      expect(currencies.single.currencyCode, 'JPY');
    });

    test('defaults isCore to false when is_core is missing', () {
      final currencies = FirestoreService.parseCurrencies(
        snapshotDate: '2025-01-01',
        ratesData: {
          'aed': {'buy': 55.0, 'sell': 56.0},
        },
      );

      expect(currencies.single.isCore, isFalse);
    });

    test('accepts int rates and converts to double', () {
      final currencies = FirestoreService.parseCurrencies(
        snapshotDate: '2025-01-01',
        ratesData: {
          'usd': {'buy': 210, 'sell': 213, 'is_core': true},
        },
      );

      expect(currencies.single.buy, 210.0);
      expect(currencies.single.sell, 213.0);
    });

    test('defaults buy/sell to 0.0 when missing', () {
      final currencies = FirestoreService.parseCurrencies(
        snapshotDate: '2025-01-01',
        ratesData: {
          'xxx': {'is_core': false},
        },
      );

      expect(currencies.single.buy, 0.0);
      expect(currencies.single.sell, 0.0);
    });

    test('leaves optional name/symbol/flag null when absent', () {
      final currencies = FirestoreService.parseCurrencies(
        snapshotDate: '2025-01-01',
        ratesData: {
          'usd': {'buy': 210.0, 'sell': 213.0, 'is_core': true},
        },
      );

      expect(currencies.single.currencyName, isNull);
      expect(currencies.single.currencySymbol, isNull);
      expect(currencies.single.flag, isNull);
    });

    test('empty ratesData returns an empty list', () {
      final currencies = FirestoreService.parseCurrencies(
        snapshotDate: '2025-01-01',
        ratesData: const {},
      );

      expect(currencies, isEmpty);
    });

    test('throws on a malformed snapshot date', () {
      expect(
        () => FirestoreService.parseCurrencies(
          snapshotDate: 'not-a-date',
          ratesData: {
            'usd': {'buy': 210.0, 'sell': 213.0, 'is_core': true},
          },
        ),
        throwsFormatException,
      );
    });
  });

  group('FirestoreService.parseHistoricalRates', () {
    test('parses ISO-date keys and numeric buy values', () {
      final history = FirestoreService.parseHistoricalRates({
        '2025-01-01': 150.5,
        '2025-02-01': 152.0,
      });

      expect(history, hasLength(2));
      expect(history.first.date, DateTime.parse('2025-01-01'));
      expect(history.first.buy, 150.5);
    });

    test('sorts entries by date ascending', () {
      final history = FirestoreService.parseHistoricalRates({
        '2025-03-01': 160.0,
        '2025-01-01': 150.0,
        '2025-02-01': 155.0,
      });

      expect(
        history.map((e) => e.date).toList(),
        [
          DateTime.parse('2025-01-01'),
          DateTime.parse('2025-02-01'),
          DateTime.parse('2025-03-01'),
        ],
      );
    });

    test('accepts int values and converts to double', () {
      final history = FirestoreService.parseHistoricalRates({
        '2025-01-01': 150,
      });

      expect(history.single.buy, 150.0);
    });

    test('defaults buy to 0.0 when value is non-numeric', () {
      final history = FirestoreService.parseHistoricalRates({
        '2025-01-01': 'oops',
      });

      expect(history.single.buy, 0.0);
    });

    test('unparseable date keys fall back to DateTime.now()', () {
      // We assert a bracketed window rather than equality — DateTime.now()
      // moves. The important behavior is: no throw, gets a real date.
      final before = DateTime.now();
      final history =
          FirestoreService.parseHistoricalRates({'not-a-date': 42});
      final after = DateTime.now();

      expect(history.single.buy, 42.0);
      expect(
        history.single.date.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        history.single.date.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('empty map returns an empty list', () {
      final history = FirestoreService.parseHistoricalRates(const {});
      expect(history, isEmpty);
    });
  });
}
