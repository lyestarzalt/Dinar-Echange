import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dinar_echange/data/models/currency_model.dart';
import 'package:dinar_echange/providers/list_currency_provider.dart';
import 'package:dinar_echange/services/preferences_service.dart';

Currency _mk(String code) => Currency(
      currencyCode: code,
      buy: 1,
      sell: 1,
      date: DateTime(2024, 1, 1),
      isCore: true,
    );

Future<ListCurrencyProvider> _newProvider() async {
  final p = ListCurrencyProvider(
    currencies: [_mk('A'), _mk('B'), _mk('C')],
    marketType: 'test',
  );
  // Constructor kicks off async _loadSelectedCurrencies; wait for it.
  await Future<void>.delayed(Duration.zero);
  return p;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService().init();
  });

  group('ListCurrencyProvider.reorderCurrencies', () {
    // These tests pin the ReorderableListView onReorderItem semantics used
    // after the Flutter 3.47 migration: newIndex is already adjusted for
    // the removed item, so no manual `newIndex -= 1` is needed.

    test('moves an item DOWN using onReorderItem-adjusted index', () async {
      final p = await _newProvider();
      expect(p.selectedCurrencies.map((c) => c.currencyCode), ['A', 'B', 'C']);

      // Drag A (0) to position 2 -> [B, C, A].
      // Under old onReorder semantics newIndex would be 3 and code would
      // subtract 1. Under onReorderItem it's already 2 and we insert as-is.
      p.reorderCurrencies(0, 2);

      expect(p.selectedCurrencies.map((c) => c.currencyCode), ['B', 'C', 'A']);
    });

    test('moves an item UP', () async {
      final p = await _newProvider();

      // Drag C (2) to position 0 -> [C, A, B].
      p.reorderCurrencies(2, 0);

      expect(p.selectedCurrencies.map((c) => c.currencyCode), ['C', 'A', 'B']);
    });

    test('no-op when oldIndex equals newIndex effect', () async {
      final p = await _newProvider();

      // Drag B (1) to position 1 -> unchanged.
      p.reorderCurrencies(1, 1);

      expect(p.selectedCurrencies.map((c) => c.currencyCode), ['A', 'B', 'C']);
    });
  });
}
