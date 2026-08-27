import 'package:flutter/material.dart';
import 'package:dinar_echange/data/currency_repository.dart';
import 'package:dinar_echange/data/models/currency_model.dart';
import 'package:dinar_echange/data/repositories/main_repository.dart';
import 'package:dinar_echange/data/models/historical_rate_model.dart';
import 'dart:math' as math;
import 'package:dinar_echange/utils/logging.dart';
import 'package:dinar_echange/utils/state.dart';

class GraphProvider with ChangeNotifier {
  final CurrencyRepository _mainRepository;
  List<Currency> coreCurrencies = [];
  Currency? selectedCurrency;
  List<CurrencyHistoryEntry> historicalData = [];

  final ValueNotifier<int> selectedPointIndex = ValueNotifier<int>(-1);
  final ValueNotifier<String> selectedExchangeRate = ValueNotifier<String>('');
  final ValueNotifier<DateTime> selectedDate =
      ValueNotifier<DateTime>(DateTime.now());

  double maxExchangeRate = 0;
  double minExchangeRate = 0;
  double averageExchangeRate = 0;
  double totalDataPoints = 0;

  // Un-buffered period statistics for the stats strip. These reflect the
  // actual data, not the chart's plotting range (which pads by 2%).
  double periodHigh = 0;
  double periodLow = 0;
  double periodAvg = 0;
  double periodChange = 0;
  double periodChangePct = 0;

  int displayPeriodDays = 180; // Default to 6 months
  final String defaultCurrencyCode = 'EUR';
  final String dateformat = 'd MMMM y';
  AppState<List<CurrencyHistoryEntry>> _state = AppState.loading();

  AppState<List<CurrencyHistoryEntry>> get state => _state;

  GraphProvider(List<Currency> allCurrencies, {CurrencyRepository? repository})
      : _mainRepository = repository ?? MainRepository() {
    fetchCurrencies(allCurrencies);
  }

  Future<void> fetchCurrencies(List<Currency> allCurrencies) async {
    if (_isDisposed) return;

    try {
      coreCurrencies =
          allCurrencies.where((currency) => currency.isCore).toList();
      selectedCurrency = coreCurrencies.firstWhere(
        (currency) => currency.currencyCode == defaultCurrencyCode,
        orElse: () => coreCurrencies.first,
      );

      // loadCurrencyHistory owns the success/error state transition —
      // do NOT overwrite it here. Previously this method blindly set
      // AppState.success after the await, silently clobbering the
      // error state set by an empty-history or repo-throw path.
      await loadCurrencyHistory();
    } catch (e) {
      AppLogger.logError('Failed to fetch currencies', error: e);
      _state = AppState.error(e.toString());
      _notifySafe();
    }
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    selectedPointIndex.dispose();
    selectedExchangeRate.dispose();
    selectedDate.dispose();
    super.dispose();
  }

  void _notifySafe() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void updateSelectedPoint(int index) {
    if (_isDisposed) return;

    if (index >= 0 && index < historicalData.length) {
      var dataPoint = historicalData[index];
      selectedPointIndex.value = index;
      // Match updateDisplayPeriod's format — bare number, no suffix.
      // The "DZD" label is a UI concern, not a provider concern.
      selectedExchangeRate.value = dataPoint.buy.toStringAsFixed(2);
      selectedDate.value = dataPoint.date;
    }
  }

  Future<void> loadCurrencyHistory() async {
    if (_isDisposed) return;

    if (selectedCurrency == null) {
      const errorMessage = 'Selected currency is not set.';
      AppLogger.logError(errorMessage, reportToSentry: false);
      _state = AppState.error(errorMessage);
      _notifySafe();
      return;
    }

    _state = AppState.loading();
    _notifySafe();

    try {
      selectedCurrency =
          await _mainRepository.getCurrencyHistory(selectedCurrency!);

      if (selectedCurrency!.history!.isEmpty) {
        const errorMessage =
            'No history data available for the selected currency.';
        AppLogger.logError(errorMessage, reportToSentry: false);
        _state = AppState.error(errorMessage);
        _notifySafe();
        return;
      }

      historicalData = selectedCurrency!.history!;
      updateDisplayPeriod(days: displayPeriodDays);

      _state = AppState.success(historicalData);
      _notifySafe();
    } catch (e) {
      // State is set + observers notified — do NOT rethrow. Callers
      // (`onCurrencySelected` on the picker, the initial fetch from the
      // constructor) don't await this future, so a rethrown exception
      // becomes an unhandled async error that shows up in the logs as
      // a scary uncaught trace on every currency switch that fails.
      AppLogger.logError('Error loading currency history', error: e);
      _state = AppState.error(e.toString());
      _notifySafe();
    }
  }

  void setDisplayPeriod(int days) {
    if (displayPeriodDays != days) {
      displayPeriodDays = days;
      updateDisplayPeriod(days: displayPeriodDays);
      AppLogger.logEvent('display_period_changed', {
        'new_period_days': days,
        'currency_code': selectedCurrency?.currencyCode ?? 'N/A'
      });
    }
  }

  void updateDisplayPeriod({int days = 180}) {
    if (selectedCurrency == null) return;

    historicalData = selectedCurrency!.getFilteredHistory(days);
    List<double> exchangeRates = historicalData.map((e) => e.buy).toList();
    if (exchangeRates.isEmpty) return;

    const bufferPercent = 0.02; // 2% buffer for graph visualization
    double highestRate = exchangeRates.reduce(math.max);
    double lowestRate = exchangeRates.reduce(math.min);
    double buffer = (highestRate - lowestRate) * bufferPercent;

    selectedExchangeRate.value = historicalData.last.buy.toStringAsFixed(2);
    selectedDate.value = historicalData.last.date;

    maxExchangeRate = highestRate + buffer;
    minExchangeRate = lowestRate - buffer;
    averageExchangeRate = (maxExchangeRate + minExchangeRate) / 2;
    totalDataPoints = historicalData.length.toDouble() - 1;

    // Period stats reflect the data itself, not the chart's padded range.
    final firstVal = exchangeRates.first;
    final lastVal = exchangeRates.last;
    double sum = 0;
    for (final v in exchangeRates) {
      sum += v;
    }
    periodHigh = highestRate;
    periodLow = lowestRate;
    periodAvg = sum / exchangeRates.length;
    periodChange = lastVal - firstVal;
    periodChangePct = firstVal > 0 ? (periodChange / firstVal) * 100 : 0;

    notifyListeners();
  }
}
