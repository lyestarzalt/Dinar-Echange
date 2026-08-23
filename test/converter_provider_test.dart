import 'package:flutter_test/flutter_test.dart';
import 'package:dinar_echange/providers/converter_provider.dart';
import 'package:dinar_echange/data/models/currency_model.dart';

// Fixture picks buy < sell to match the universal FX / Achat-Vente convention.
// buy=100 (exchanger's bid), sell=110 (exchanger's ask).
Currency _mk({double buy = 100, double sell = 110}) => Currency(
      currencyCode: 'EUR',
      buy: buy,
      sell: sell,
      date: DateTime(2024, 1, 1),
      isCore: true,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CurrencyConverterProvider', () {
    test('initial state: 100 foreign converts to DZD at the buy rate', () {
      final p = CurrencyConverterProvider(_mk(buy: 100, sell: 110));
      addTearDown(p.dispose);

      expect(p.isDZDtoCurrency, isFalse);
      expect(p.useCentimes, isFalse);
      expect(p.amountController.text, '100');
      // Customer selling 100 EUR → exchanger uses BID (buy=100).
      expect(p.resultController.text, '10,000');
      expect(p.conversionRate, 100);
    });

    test('editing amount recomputes result using buy rate', () {
      final p = CurrencyConverterProvider(_mk(buy: 100, sell: 110));
      addTearDown(p.dispose);

      p.amountController.text = '50';

      expect(p.resultController.text, '5,000');
    });

    test('toggleConversionDirection swaps controllers and applies 1/sell rate',
        () {
      // 1.4.8 regression: previously the result did not update when
      // switching direction. This pins the fixed behavior.
      final p = CurrencyConverterProvider(_mk(buy: 100, sell: 110));
      addTearDown(p.dispose);
      // Before: amount=100 EUR, result=10,000 DZD, rate=100 (buy).

      p.toggleConversionDirection();

      expect(p.isDZDtoCurrency, isTrue);
      // Customer buying EUR now → exchanger uses ASK (sell=110), so 1 DZD
      // is worth 1/110 EUR.
      expect(p.conversionRate, 1 / 110);
      // After the swap, amountController holds the previous result ("10,000")
      // and the recomputation is 10000 * (1/110) ≈ 90.909, no decimals → "91".
      expect(p.amountController.text, '10,000');
      expect(p.resultController.text, '91');
    });

    test('toggleCentimes switches result to 2 decimal places', () {
      final p = CurrencyConverterProvider(_mk(buy: 100.5, sell: 110));
      addTearDown(p.dispose);
      expect(p.resultController.text, '10,050'); // no decimals initially

      p.toggleCentimes();

      expect(p.useCentimes, isTrue);
      expect(p.resultController.text, '10,050.00');
    });

    test('empty amount clears the result', () {
      final p = CurrencyConverterProvider(_mk());
      addTearDown(p.dispose);

      p.amountController.text = '';

      expect(p.resultController.text, isEmpty);
    });

    test('non-numeric amount clears the result', () {
      final p = CurrencyConverterProvider(_mk());
      addTearDown(p.dispose);

      p.amountController.text = 'abc';

      expect(p.resultController.text, isEmpty);
    });

    test('zero amount clears the result', () {
      final p = CurrencyConverterProvider(_mk());
      addTearDown(p.dispose);

      p.amountController.text = '0';

      expect(p.resultController.text, isEmpty);
    });

    test('currency with sell=0 yields inverse rate of 0 (no NaN)', () {
      // sell=0 is the divide-by-zero case for the DZD→foreign direction now
      // that we correctly use 1/sell there.
      final p = CurrencyConverterProvider(_mk(buy: 100, sell: 0));
      addTearDown(p.dispose);

      p.toggleConversionDirection();

      expect(p.conversionRate, 0);
      // 10,000 * 0 = 0 → formatted "0"
      expect(p.resultController.text, '0');
    });
  });
}
