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
  List<CurrencyHistoryEntry> filteredHistoryEntries = [];
  final ValueNotifier<int> touchedIndex = ValueNotifier<int>(-1);
  final ValueNotifier<String> selectedValue = ValueNotifier<String>('');
  final ValueNotifier<DateTime> selectedDate =
      ValueNotifier<DateTime>(DateTime.now());

  double maxYValue = 0, minYValue = 0, midYValue = 0, maxX = 0;
  int timeSpan = 180; // Default to 6 months
  final String defaultCurrencyCode = 'EUR'; // Default currency
  final String dateformat = 'd MMMM y';
  AppState _state = AppState.loading();

  AppState get state => _state;

  GraphProvider(List<Currency> allCurrencies) {
    fetchCurrencies(allCurrencies);
  }

  Future<void> fetchCurrencies(List<Currency> allCurrencies) async {
    try {
      _state = AppState.loading();
      notifyListeners();
      coreCurrencies =
          allCurrencies.where((currency) => currency.isCore).toList();
      selectedCurrency = coreCurrencies.firstWhere(
        (currency) => currency.currencyCode == defaultCurrencyCode,
        orElse: () => coreCurrencies.first,
      );
      await loadCurrencyHistory();
      _state = AppState.success(filteredHistoryEntries);
      notifyListeners();
    } catch (e) {
      AppLogger.logError("Failed to fetch currencies", error: e);
      _state = AppState.error(e.toString());
      //TODO
      /*       FlutterError (A GraphProvider was used after being disposed.
        Once you have called dispose() on a GraphProvider, it can no longer be used.) */
      _notifySafe();
    }
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _notifySafe() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void updateSelectedData(int index) {
    if (index >= 0 && index < filteredHistoryEntries.length) {
      var entry = filteredHistoryEntries[index];
      touchedIndex.value = index;
      selectedValue.value = '${entry.buy.toStringAsFixed(2)} DZD';
      selectedDate.value = entry.date;
    }
  }

  Future<void> loadCurrencyHistory() async {
    if (selectedCurrency == null) {
      const errorMessage = 'Selected currency is not set.';
      AppLogger.logError(errorMessage);
      _state = AppState.error(errorMessage);
      notifyListeners();
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

      filteredHistoryEntries = selectedCurrency!.history!;
      processData(days: timeSpan);

      _state = AppState.success(filteredHistoryEntries);
      notifyListeners();
    } catch (e) {
      AppLogger.logError('Error loading currency history: ${e.toString()}',
          error: e);
      _state = AppState.error(e.toString());
      notifyListeners();
      //_Exception (Exception: Failed to load currency history due to an error: [cloud_firestore/unavailable]
      //The service is currently unavailable. This is a most likely a transient condition and may be corrected
      // by retrying with a backoff.)
      throw Exception(
          'Failed to load currency history due to an error: ${e.toString()}');
    }
  }
void setTimeSpan(int days) {
    if (timeSpan != days) {
      timeSpan = days;
      processData(days: timeSpan);
      AppLogger.logEvent('time_span_changed', {
        'new_time_span_days': days,
        'currency_code': selectedCurrency?.currencyCode ?? 'N/A'
      });
    }
  }

  void processData({int days = 180}) {
    if (selectedCurrency == null) return;

    filteredHistoryEntries = selectedCurrency!.getFilteredHistory(days);
    List<double> allBuyValues =
        filteredHistoryEntries.map((e) => e.buy).toList();
    const bufferPercent = 0.02; // 2% buffer
    double maxDataValue = allBuyValues.reduce(math.max);
    double minDataValue = allBuyValues.reduce(math.min);
    double bufferValue = (maxDataValue - minDataValue) * bufferPercent;
    selectedValue.value = filteredHistoryEntries.isNotEmpty
        ? filteredHistoryEntries.last.buy.toStringAsFixed(2)
        : '';
    selectedDate.value = filteredHistoryEntries.last.date;

    maxYValue = maxDataValue + bufferValue;
    minYValue = minDataValue - bufferValue;
    midYValue = (maxYValue + minYValue) / 2;
    maxX = filteredHistoryEntries.length.toDouble() - 1;
    notifyListeners();
  }
}
