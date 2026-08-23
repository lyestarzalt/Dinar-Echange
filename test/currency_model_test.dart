import 'package:flutter_test/flutter_test.dart';
import 'package:dinar_echange/data/models/currency_model.dart';
import 'package:dinar_echange/data/models/historical_rate_model.dart';

void main() {
  group('Currency.fromJson', () {
    test('parses a fully-populated payload', () {
      final json = <String, dynamic>{
        'currencyCode': 'EUR',
        'buy': 145.5,
        'sell': 148.2,
        'date': '2024-06-01T00:00:00.000',
        'isCore': true,
        'name': 'Euro',
        'symbol': '€',
        'flag': 'https://example.com/eu.png',
        'history': [
          {'date': '2024-05-30T00:00:00.000', 'buy': 144.0},
          {'date': '2024-05-31T00:00:00.000', 'buy': 145.0},
        ],
      };

      final c = Currency.fromJson(json);

      expect(c.currencyCode, 'EUR');
      expect(c.buy, 145.5);
      expect(c.sell, 148.2);
      expect(c.date, DateTime.parse('2024-06-01T00:00:00.000'));
      expect(c.isCore, isTrue);
      expect(c.currencyName, 'Euro');
      expect(c.currencySymbol, '€');
      expect(c.flag, 'https://example.com/eu.png');
      expect(c.history, hasLength(2));
      expect(c.history!.first.buy, 144.0);
    });

    test('missing optional fields default sensibly', () {
      final json = <String, dynamic>{
        'currencyCode': 'USD',
        'buy': 130.0,
        'sell': 132.0,
        'date': '2024-06-01T00:00:00.000',
      };

      final c = Currency.fromJson(json);

      expect(c.isCore, isFalse);
      expect(c.currencyName, isNull);
      expect(c.currencySymbol, isNull);
      expect(c.flag, isNull);
      expect(c.history, isNull);
    });

    test('null buy/sell coerce to 0.0', () {
      final json = <String, dynamic>{
        'currencyCode': 'X',
        'buy': null,
        'sell': null,
        'date': '2024-06-01T00:00:00.000',
      };

      final c = Currency.fromJson(json);

      expect(c.buy, 0.0);
      expect(c.sell, 0.0);
    });
  });

  test('toJson -> fromJson is a stable roundtrip', () {
    final original = Currency(
      currencyCode: 'GBP',
      buy: 170.0,
      sell: 172.5,
      date: DateTime.parse('2024-06-01T00:00:00.000'),
      isCore: true,
      currencyName: 'Pound',
      currencySymbol: '£',
      history: [
        CurrencyHistoryEntry(
            date: DateTime.parse('2024-05-30T00:00:00.000'), buy: 169.0),
      ],
    );

    final decoded = Currency.fromJson(original.toJson());

    expect(decoded.currencyCode, original.currencyCode);
    expect(decoded.buy, original.buy);
    expect(decoded.sell, original.sell);
    expect(decoded.date, original.date);
    expect(decoded.isCore, original.isCore);
    expect(decoded.currencyName, original.currencyName);
    expect(decoded.currencySymbol, original.currencySymbol);
    expect(decoded.history!.first.buy, 169.0);
  });

  group('Currency.getFilteredHistory', () {
    Currency withHistoryLength(int n) => Currency(
          currencyCode: 'EUR',
          buy: 1,
          sell: 1,
          date: DateTime(2024, 1, 1),
          isCore: false,
          history: List.generate(
            n,
            (i) => CurrencyHistoryEntry(
                date: DateTime(2024, 1, 1).add(Duration(days: i)),
                buy: i.toDouble()),
          ),
        );

    test('returns empty list when history is null or empty', () {
      final c1 = Currency(
        currencyCode: 'X',
        buy: 1,
        sell: 1,
        date: DateTime(2024),
        isCore: false,
      );
      expect(c1.getFilteredHistory(30), isEmpty);
      expect(withHistoryLength(0).getFilteredHistory(30), isEmpty);
    });

    test('returns full history when timeSpan >= length', () {
      final c = withHistoryLength(10);
      expect(c.getFilteredHistory(10), hasLength(10));
      expect(c.getFilteredHistory(999), hasLength(10));
    });

    test('returns the last N entries when timeSpan < length', () {
      final c = withHistoryLength(10);

      final tail = c.getFilteredHistory(3);

      expect(tail, hasLength(3));
      expect(tail.map((e) => e.buy), [7.0, 8.0, 9.0]);
    });
  });
}
