import 'package:flutter_test/flutter_test.dart';
import 'package:dinar_echange/providers/converter_provider.dart';
import 'package:dinar_echange/data/models/currency_model.dart';

// Realistic fixture: USD at Aug-2026 parallel-market spread — buy=236 (bid),
// sell=239 (ask), so buy < sell per the universal FX / Achat-Vente convention.
Currency _usd() => Currency(
      currencyCode: 'USD',
      buy: 236.0,
      sell: 239.0,
      date: DateTime.parse('2026-08-23'),
      isCore: true,
    );

void main() {
  group('CurrencyConverterProvider.rateFor', () {
    test('foreign → DZD uses buy (the exchanger bid)', () {
      final rate = CurrencyConverterProvider.rateFor(
        currency: _usd(),
        isDZDtoCurrency: false,
      );

      expect(rate, 236.0);
      expect(100 * rate, closeTo(23600.0, 1e-9));
    });

    test('DZD → foreign uses 1/sell (the exchanger ask)', () {
      final rate = CurrencyConverterProvider.rateFor(
        currency: _usd(),
        isDZDtoCurrency: true,
      );

      expect(rate, closeTo(1 / 239.0, 1e-12));
      expect(100 * rate, closeTo(100 / 239.0, 1e-9));
    });

    test('regression: foreign→DZD must NOT multiply by sell', () {
      // The historical bug: converter used sell for foreign→DZD, making the
      // app pay users the "ask" rate instead of the "bid" rate — 1.3% too
      // generous. This test locks the corrected direction in place.
      final usd = _usd();
      final actualDzd =
          100 * CurrencyConverterProvider.rateFor(
              currency: usd, isDZDtoCurrency: false);
      final buggyDzd = 100 * usd.sell;

      expect(actualDzd, lessThan(buggyDzd));
      expect(buggyDzd - actualDzd, closeTo(100 * (usd.sell - usd.buy), 1e-9));
    });

    test('regression: DZD→foreign must NOT divide by buy', () {
      final usd = _usd();
      final actualUsd =
          100 * CurrencyConverterProvider.rateFor(
              currency: usd, isDZDtoCurrency: true);
      final buggyUsd = 100 / usd.buy;

      expect(actualUsd, lessThan(buggyUsd));
    });

    test('buy < sell holds for the parallel market fixture', () {
      // Sanity: if this ever fails the fixture is wrong, not the code.
      final usd = _usd();
      expect(usd.buy, lessThan(usd.sell));
    });

    test('returns 0 for DZD→foreign when sell is 0 (guards divide-by-zero)',
        () {
      final broken = Currency(
        currencyCode: 'XYZ',
        buy: 100.0,
        sell: 0.0,
        date: DateTime.parse('2026-08-23'),
        isCore: false,
      );

      final rate = CurrencyConverterProvider.rateFor(
        currency: broken,
        isDZDtoCurrency: true,
      );

      expect(rate, 0.0);
    });

    test('foreign→DZD returns 0 when buy is 0 (no data yet)', () {
      final empty = Currency(
        currencyCode: 'XYZ',
        buy: 0.0,
        sell: 0.0,
        date: DateTime.parse('2026-08-23'),
        isCore: false,
      );

      final rate = CurrencyConverterProvider.rateFor(
        currency: empty,
        isDZDtoCurrency: false,
      );

      expect(rate, 0.0);
    });

    test('round-trip loses only the spread, never gains value', () {
      // Convert 100 USD → DZD → back to USD. Must be strictly less than 100
      // (the customer eats the spread on both legs). This catches any future
      // regression that accidentally makes conversions symmetric.
      final usd = _usd();
      final asDzd =
          100 * CurrencyConverterProvider.rateFor(
              currency: usd, isDZDtoCurrency: false);
      final backToUsd = asDzd *
          CurrencyConverterProvider.rateFor(
              currency: usd, isDZDtoCurrency: true);

      expect(backToUsd, lessThan(100));
      // With 236/239 spread, round-trip ≈ 98.7 USD.
      expect(backToUsd, closeTo(100 * 236 / 239, 1e-9));
    });
  });
}
