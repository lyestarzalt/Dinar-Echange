import 'package:flutter_test/flutter_test.dart';
import 'package:dinar_echange/providers/converter_provider.dart';
import 'package:dinar_echange/data/models/currency_model.dart';

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
    test('initial state: 100 * sell rate, no decimals, EUR->DZD direction', () {
      final p = CurrencyConverterProvider(_mk(sell: 110));
      addTearDown(p.dispose);

      expect(p.isDZDtoCurrency, isFalse);
      expect(p.useCentimes, isFalse);
      expect(p.amountController.text, '100');
      expect(p.resultController.text, '11,000');
      expect(p.conversionRate, 110);
    });

    test('editing amount recomputes result using sell rate', () {
      final p = CurrencyConverterProvider(_mk(sell: 110));
      addTearDown(p.dispose);

      p.amountController.text = '50';

      expect(p.resultController.text, '5,500');
    });

    test('toggleConversionDirection swaps controllers and applies inverse rate',
        () {
      // 1.4.8 regression: previously the result did not update when
      // switching direction. This pins the fixed behavior.
      final p = CurrencyConverterProvider(_mk(buy: 100, sell: 110));
      addTearDown(p.dispose);
      // Before: amount=100, result=11,000, rate=110 (sell)

      p.toggleConversionDirection();

      expect(p.isDZDtoCurrency, isTrue);
      expect(p.conversionRate, 1 / 100); // inverse of buy
      // After swap+recompute: amountController="11,000" -> parsed 11000
      // 11000 * (1/100) = 110 -> formatted "110"
      expect(p.amountController.text, '11,000');
      expect(p.resultController.text, '110');
    });

    test('toggleCentimes switches result to 2 decimal places', () {
      final p = CurrencyConverterProvider(_mk(sell: 110.5));
      addTearDown(p.dispose);
      expect(p.resultController.text, '11,050'); // no decimals initially

      p.toggleCentimes();

      expect(p.useCentimes, isTrue);
      expect(p.resultController.text, '11,050.00');
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

    test('currency with buy=0 yields inverse rate of 0 (no NaN)', () {
      final p = CurrencyConverterProvider(_mk(buy: 0, sell: 110));
      addTearDown(p.dispose);

      p.toggleConversionDirection();

      expect(p.conversionRate, 0);
      // 11,000 * 0 = 0 -> formatted "0"
      expect(p.resultController.text, '0');
    });
  });
}
