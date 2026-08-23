import 'package:flutter_test/flutter_test.dart';
import 'package:dinar_echange/data/services/http_rates_service.dart';

// Guards against R2 payload drift breaking the client. The fixture below is
// a trimmed copy of what the scraper Lambda writes to R2; if the backend
// changes the shape without a coordinated release, these tests fail before
// the change reaches production.
void main() {
  group('HttpRatesService.parseRates', () {
    test('parses the full R2 payload shape into Currency objects', () {
      final payload = <String, dynamic>{
        'date': '2026-08-23',
        'rates': {
          'EUR': {
            'currencyCode': 'EUR',
            'name': 'Euro',
            'symbol': '€',
            'flag': 'https://flagcdn.com/w80/eu.png',
            'buy': 273.0,
            'sell': 275.0,
            'date': '2026-08-22',
            'is_core': true,
          },
          'USD': {
            'currencyCode': 'USD',
            'name': 'United States dollar',
            'symbol': r'$',
            'flag': 'https://flagcdn.com/w80/us.png',
            'buy': 236.0,
            'sell': 239.0,
            'date': '2026-08-22',
            'is_core': true,
          },
        },
      };

      final result = HttpRatesService.parseRates(payload);

      expect(result, hasLength(2));

      final eur = result.firstWhere((c) => c.currencyCode == 'EUR');
      expect(eur.buy, 273.0);
      expect(eur.sell, 275.0);
      expect(eur.isCore, true);
      expect(eur.currencyName, 'Euro');
      expect(eur.currencySymbol, '€');
      expect(eur.flag, 'https://flagcdn.com/w80/eu.png');
      // The top-level 'date' is the snapshot date and drives all entries.
      expect(eur.date, DateTime.parse('2026-08-23'));

      final usd = result.firstWhere((c) => c.currencyCode == 'USD');
      expect(usd.buy, 236.0);
      expect(usd.sell, 239.0);
    });

    test('maps snake_case is_core onto Dart-side isCore', () {
      final result = HttpRatesService.parseRates({
        'date': '2026-08-23',
        'rates': {
          'AED': {
            'buy': 60.0,
            'sell': 62.0,
            'is_core': true,
          },
          'BAM': {
            'buy': 140.0,
            'sell': 143.0,
            'is_core': false,
          },
        },
      });

      expect(result.firstWhere((c) => c.currencyCode == 'AED').isCore, true);
      expect(result.firstWhere((c) => c.currencyCode == 'BAM').isCore, false);
    });

    test('defaults isCore to false when is_core is missing', () {
      final result = HttpRatesService.parseRates({
        'date': '2026-08-23',
        'rates': {
          'XYZ': {'buy': 1.0, 'sell': 2.0},
        },
      });

      expect(result.single.isCore, false);
    });

    test('accepts int rates and converts to double', () {
      final result = HttpRatesService.parseRates({
        'date': '2026-08-23',
        'rates': {
          'USD': {'buy': 236, 'sell': 239, 'is_core': true},
        },
      });

      expect(result.single.buy, 236.0);
      expect(result.single.sell, 239.0);
    });

    test('uppercases the currency code taken from the map key', () {
      final result = HttpRatesService.parseRates({
        'date': '2026-08-23',
        'rates': {
          'usd': {'buy': 236.0, 'sell': 239.0, 'is_core': true},
        },
      });

      expect(result.single.currencyCode, 'USD');
    });

    test('leaves optional name/symbol/flag null when absent', () {
      final result = HttpRatesService.parseRates({
        'date': '2026-08-23',
        'rates': {
          'ZAR': {'buy': 12.0, 'sell': 13.0, 'is_core': false},
        },
      });

      expect(result.single.currencyName, isNull);
      expect(result.single.currencySymbol, isNull);
      expect(result.single.flag, isNull);
    });

    test('returns an empty list when rates map is empty', () {
      final result = HttpRatesService.parseRates({
        'date': '2026-08-23',
        'rates': <String, dynamic>{},
      });

      expect(result, isEmpty);
    });

    test('throws when top-level date is missing', () {
      expect(
        () => HttpRatesService.parseRates({
          'rates': {'USD': {'buy': 1.0, 'sell': 2.0, 'is_core': true}},
        }),
        throwsA(isA<Exception>()),
      );
    });

    test('throws when rates key is missing', () {
      expect(
        () => HttpRatesService.parseRates({'date': '2026-08-23'}),
        throwsA(isA<Exception>()),
      );
    });

    test('throws on malformed date string', () {
      expect(
        () => HttpRatesService.parseRates({
          'date': 'not-a-date',
          'rates': {'USD': {'buy': 1.0, 'sell': 2.0, 'is_core': true}},
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
