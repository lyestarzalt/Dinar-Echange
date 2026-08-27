import 'package:dinar_echange/data/currency_repository.dart';
import 'package:dinar_echange/data/models/currency_model.dart';
import 'package:dinar_echange/data/models/historical_rate_model.dart';
import 'package:dinar_echange/providers/graph_provider.dart';
import 'package:dinar_echange/utils/enums.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hand-rolled fake repo. Follows the memory-rule preference against
/// mocking frameworks for critical paths — behavior is explicit,
/// deterministic, and readable.
class _FakeRepository implements CurrencyRepository {
  _FakeRepository({
    this.historyByCode = const {},
    this.throwOnHistory = false,
  });

  final Map<String, List<CurrencyHistoryEntry>> historyByCode;
  final bool throwOnHistory;
  int historyCallCount = 0;

  @override
  Future<Currency> getCurrencyHistory(Currency currency) async {
    historyCallCount++;
    if (throwOnHistory) {
      throw StateError('repo blew up');
    }
    currency.history = historyByCode[currency.currencyCode] ?? [];
    return currency;
  }

  @override
  Future<List<Currency>> getDailyCurrencies() async => [];

  @override
  Future<List<Currency>> getOfficialDailyCurrencies() async => [];
}

Currency _c(String code, {bool isCore = true}) => Currency(
      currencyCode: code,
      buy: 1,
      sell: 1,
      date: DateTime(2026, 1, 1),
      isCore: isCore,
    );

CurrencyHistoryEntry _h(String iso, double buy) =>
    CurrencyHistoryEntry(date: DateTime.parse(iso), buy: buy);

Future<GraphProvider> _newProvider(
  List<Currency> currencies, {
  required _FakeRepository repo,
}) async {
  final provider = GraphProvider(currencies, repository: repo);
  // fetchCurrencies is fire-and-forget from the constructor — pump the
  // event queue so the async chain (fetch → loadCurrencyHistory →
  // updateDisplayPeriod → notify) settles before assertions.
  await Future<void>.delayed(Duration.zero);
  return provider;
}

void main() {
  group('GraphProvider selection', () {
    test('picks EUR by default when EUR is a core currency', () async {
      final repo = _FakeRepository(historyByCode: {
        'EUR': [_h('2025-01-01', 150), _h('2025-06-01', 155)],
        'USD': [_h('2025-01-01', 130)],
      });
      final p = await _newProvider(
        [_c('USD'), _c('EUR'), _c('GBP')],
        repo: repo,
      );

      expect(p.selectedCurrency?.currencyCode, 'EUR');
      expect(p.coreCurrencies.map((c) => c.currencyCode).toList(),
          ['USD', 'EUR', 'GBP']);
    });

    test('falls back to first core currency when EUR is missing', () async {
      final repo = _FakeRepository(historyByCode: {
        'USD': [_h('2025-01-01', 130)],
      });
      final p = await _newProvider([_c('USD'), _c('GBP')], repo: repo);

      expect(p.selectedCurrency?.currencyCode, 'USD');
    });

    test('filters out non-core currencies', () async {
      final repo = _FakeRepository(historyByCode: {
        'USD': [_h('2025-01-01', 130)],
      });
      final p = await _newProvider(
        [_c('USD'), _c('AED', isCore: false), _c('KRW', isCore: false)],
        repo: repo,
      );

      expect(p.coreCurrencies.map((c) => c.currencyCode).toList(), ['USD']);
    });
  });

  group('GraphProvider state transitions', () {
    test('successful load → state.success and historicalData populated',
        () async {
      final repo = _FakeRepository(historyByCode: {
        'EUR': [
          _h('2025-01-01', 150),
          _h('2025-06-01', 155),
          _h('2025-12-01', 160),
        ],
      });
      final p = await _newProvider([_c('EUR')], repo: repo);

      expect(p.state.state, LoadState.success);
      expect(p.historicalData, isNotEmpty);
      expect(p.historicalData.last.buy, 160);
    });

    test('empty history → state.error with the missing-history message',
        () async {
      final repo = _FakeRepository(historyByCode: {'EUR': []});
      final p = await _newProvider([_c('EUR')], repo: repo);

      expect(p.state.state, LoadState.error);
      expect(p.state.errorMessage,
          contains('No history data available'));
    });

    test('repository throwing does NOT leak an uncaught async error',
        () async {
      // Regression check for the "unhandled async exception on picker"
      // bug fixed in graph_provider.dart:130 — loadCurrencyHistory must
      // set error state without rethrowing.
      final repo = _FakeRepository(throwOnHistory: true);
      final p = await _newProvider([_c('EUR')], repo: repo);

      expect(p.state.state, LoadState.error);
      expect(p.state.errorMessage, contains('repo blew up'));
    });

    test('null selectedCurrency short-circuits with an error state',
        () async {
      final repo = _FakeRepository(historyByCode: {'EUR': [_h('2025-01-01', 1)]});
      final p = await _newProvider([_c('EUR')], repo: repo);

      // Force the null branch by resetting selection and re-invoking
      // loadCurrencyHistory directly.
      p.selectedCurrency = null;
      await p.loadCurrencyHistory();

      expect(p.state.state, LoadState.error);
      expect(p.state.errorMessage, contains('Selected currency is not set'));
    });
  });

  group('GraphProvider period statistics', () {
    late GraphProvider provider;

    setUp(() async {
      final repo = _FakeRepository(historyByCode: {
        'EUR': [
          _h('2025-06-01', 150),
          _h('2025-07-01', 160),
          _h('2025-08-01', 155),
          _h('2025-09-01', 170),
        ],
      });
      provider = await _newProvider([_c('EUR')], repo: repo);
    });

    test('period stats reflect the raw data, not the padded chart range', () {
      // Chart range uses ±2% buffer for visual padding — stats must not.
      expect(provider.periodHigh, 170);
      expect(provider.periodLow, 150);
      expect(provider.maxExchangeRate, greaterThan(170));
      expect(provider.minExchangeRate, lessThan(150));
    });

    test('periodAvg is the arithmetic mean', () {
      expect(provider.periodAvg, closeTo((150 + 160 + 155 + 170) / 4, 1e-9));
    });

    test('periodChange = last - first, periodChangePct is percent of first',
        () {
      expect(provider.periodChange, 170 - 150);
      expect(provider.periodChangePct, closeTo(((170 - 150) / 150) * 100, 1e-9));
    });

    test('setDisplayPeriod triggers a recompute only when the value changes',
        () async {
      final beforeDays = provider.displayPeriodDays;
      provider.setDisplayPeriod(beforeDays); // same value → no-op
      expect(provider.displayPeriodDays, beforeDays);

      provider.setDisplayPeriod(30);
      expect(provider.displayPeriodDays, 30);
    });
  });

  test(
      'periodChangePct handles a zero starting value without dividing by zero',
      () async {
    final repo = _FakeRepository(historyByCode: {
      'EUR': [_h('2025-06-01', 0), _h('2025-07-01', 10)],
    });
    final p = await _newProvider([_c('EUR')], repo: repo);

    expect(p.periodChangePct, 0);
    expect(p.periodChange, 10);
  });

  group('GraphProvider selected point', () {
    late GraphProvider provider;

    setUp(() async {
      final repo = _FakeRepository(historyByCode: {
        'EUR': [
          _h('2025-06-01', 150.123),
          _h('2025-07-01', 160.987),
        ],
      });
      provider = await _newProvider([_c('EUR')], repo: repo);
    });

    test('updateSelectedPoint sets the ValueNotifiers to the point at index',
        () {
      provider.updateSelectedPoint(0);
      expect(provider.selectedPointIndex.value, 0);
      expect(provider.selectedExchangeRate.value, '150.12');
      expect(provider.selectedDate.value, DateTime.parse('2025-06-01'));
    });

    test('updateSelectedPoint ignores out-of-range indices', () {
      final beforeIdx = provider.selectedPointIndex.value;
      provider.updateSelectedPoint(-1);
      provider.updateSelectedPoint(999);
      expect(provider.selectedPointIndex.value, beforeIdx);
    });
  });

  test('dispose stops subsequent notify + selection updates', () async {
    final repo = _FakeRepository(historyByCode: {
      'EUR': [_h('2025-06-01', 150), _h('2025-07-01', 160)],
    });
    final p = await _newProvider([_c('EUR')], repo: repo);
    final idxBefore = p.selectedPointIndex.value;

    p.dispose();
    // These must not throw and must not touch the disposed notifiers.
    p.updateSelectedPoint(0);
    await p.loadCurrencyHistory();
    expect(p.selectedPointIndex.value, idxBefore);
  });
}
