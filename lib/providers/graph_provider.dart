import 'package:flutter/material.dart';
import 'package:dinar_echange/data/models/currency.dart';
import 'package:dinar_echange/data/repositories/main_repository.dart';
import 'package:dinar_echange/data/models/currency_history.dart';
import 'dart:math' as math;
import 'package:dinar_echange/utils/logging.dart';
import 'package:dinar_echange/utils/state.dart';

class GraphProvider with ChangeNotifier {
  final MainRepository _mainRepository = MainRepository();
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

  int displayPeriodDays = 180; // Default to 6 months
  final String defaultCurrencyCode = 'EUR';
  final String dateformat = 'd MMMM y';
  AppState _state = AppState.loading();

  AppState get state => _state;

  GraphProvider(List<Currency> allCurrencies) {
    fetchCurrencies(allCurrencies);
  }

  Future<void> fetchCurrencies(List<Currency> allCurrencies) async {
    if (_isDisposed) return;

    try {
      _state = AppState.loading();
      _notifySafe();

      coreCurrencies =
          allCurrencies.where((currency) => currency.isCore).toList();
      selectedCurrency = coreCurrencies.firstWhere(
        (currency) => currency.currencyCode == defaultCurrencyCode,
        orElse: () => coreCurrencies.first,
      );

      await loadCurrencyHistory();
      _state = AppState.success(historicalData);
      _notifySafe();
    } catch (e) {
      AppLogger.logError("Failed to fetch currencies", error: e);
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
      selectedExchangeRate.value = '${dataPoint.buy.toStringAsFixed(2)} DZD';
      selectedDate.value = dataPoint.date;
    }
  }

  Future<void> loadCurrencyHistory() async {
    if (_isDisposed) return;

    if (selectedCurrency == null) {
      const errorMessage = 'Selected currency is not set.';
      AppLogger.logError(errorMessage);
      _state = AppState.error(errorMessage);
      _notifySafe();
      throw Exception(errorMessage);
    }

    try {
      _state = AppState.loading();
      notifyListeners();

      selectedCurrency =
          await _mainRepository.getCurrencyHistory(selectedCurrency!);

      if (selectedCurrency!.history!.isEmpty) {
        const errorMessage =
            'No history data available for the selected currency.';
        AppLogger.logError(errorMessage);
        _state = AppState.error(errorMessage);
        notifyListeners();
        throw Exception(errorMessage);
      }

      historicalData = selectedCurrency!.history!;
      updateDisplayPeriod(days: displayPeriodDays);

      _state = AppState.success(historicalData);
      notifyListeners();
    } catch (e) {
      AppLogger.logError('Error loading currency history', error: e);
      _state = AppState.error(e.toString());
      notifyListeners();
      throw Exception('Failed to load currency history: ${e.toString()}');
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

    const bufferPercent = 0.02; // 2% buffer for graph visualization
    double highestRate = exchangeRates.reduce(math.max);
    double lowestRate = exchangeRates.reduce(math.min);
    double buffer = (highestRate - lowestRate) * bufferPercent;

    selectedExchangeRate.value = historicalData.isNotEmpty
        ? historicalData.last.buy.toStringAsFixed(2)
        : '';
    selectedDate.value = historicalData.last.date;

    maxExchangeRate = highestRate + buffer;
    minExchangeRate = lowestRate - buffer;
    averageExchangeRate = (maxExchangeRate + minExchangeRate) / 2;
    totalDataPoints = historicalData.length.toDouble() - 1;

    notifyListeners();
  }
}
