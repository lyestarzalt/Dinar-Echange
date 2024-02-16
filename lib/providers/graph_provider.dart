import 'package:flutter/material.dart';
import 'package:dinar_watch/data/models/currency.dart';
import 'package:dinar_watch/data/repositories/main_repository.dart';
import 'package:dinar_watch/data/models/currency_history.dart';
import 'dart:math' as math;
import 'package:dinar_watch/utils/logging.dart';
import 'package:dinar_watch/utils/enums.dart';

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
  final int timeSpan = 180; // Default to 6 months
  final String defaultCurrencyCode = 'EUR'; // Default currency
  final String dateformat = 'd MMMM y';
  GraphState _state = GraphState.loading();

  GraphState get state => _state;

  GraphProvider(List<Currency> allCurrencies) {
    fetchCurrencies(allCurrencies);
  }

  Future<void> fetchCurrencies(List<Currency> allCurrencies) async {
    try {
      _state = GraphState.loading();
      notifyListeners();
      coreCurrencies =
          allCurrencies.where((currency) => currency.isCore).toList();
      selectedCurrency = coreCurrencies.firstWhere(
        (currency) => currency.currencyCode == defaultCurrencyCode,
        orElse: () => coreCurrencies.first,
      );
      await loadCurrencyHistory();
      _state = GraphState.success(filteredHistoryEntries);
      notifyListeners();
    } catch (e) {
      AppLogger.logError("Failed to fetch currencies", error: e);
      _state = GraphState.error(e.toString());
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
      _state = GraphState.error(errorMessage);
      notifyListeners();
      throw Exception(errorMessage);
    }

    try {
      _state = GraphState.loading();
      notifyListeners();

      selectedCurrency =
          await _mainRepository.getCurrencyHistory(selectedCurrency!);

      if (selectedCurrency!.history!.isEmpty) {
        const errorMessage =
            'No history data available for the selected currency.';
        AppLogger.logError(errorMessage);
        _state = GraphState.error(errorMessage);
        notifyListeners();
        throw Exception(errorMessage);
      }

      filteredHistoryEntries = selectedCurrency!.history!;
      processData(days: timeSpan);

      _state = GraphState.success(filteredHistoryEntries);
      notifyListeners();
    } catch (e) {
      // Log the exception
      AppLogger.logError('Error loading currency history: ${e.toString()}',
          error: e);
      // Update the state to error and notify listeners
      _state = GraphState.error(e.toString());
      notifyListeners();
      // Rethrow the exception or handle it based on your app's needs
      throw Exception(
          'Failed to load currency history due to an error: ${e.toString()}');
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

class GraphState {
  LoadState state;
  List<CurrencyHistoryEntry>? historyEntries;
  String? errorMessage;

  GraphState._({required this.state, this.historyEntries, this.errorMessage});

  factory GraphState.loading() => GraphState._(state: LoadState.loading);

  factory GraphState.success(List<CurrencyHistoryEntry> historyEntries) =>
      GraphState._(state: LoadState.success, historyEntries: historyEntries);

  factory GraphState.error(String message) =>
      GraphState._(state: LoadState.error, errorMessage: message);
}
