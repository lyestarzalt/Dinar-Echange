import 'package:flutter/material.dart';
import 'package:dinar_watch/data/models/currency.dart';
import 'package:dinar_watch/data/repositories/main_repository.dart';
import 'package:dinar_watch/data/models/currency_history.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:dinar_watch/utils/logging.dart';

class CurrencyHistoryProvider with ChangeNotifier {
  final MainRepository _mainRepository = MainRepository();
  List<Currency> coreCurrencies = [];
  Currency? selectedCurrency;
  List<CurrencyHistoryEntry> filteredHistoryEntries = [];
  int touchedIndex = -1;
  String selectedValue = '';
  String selectedDate = '';
  double maxYValue = 0, minYValue = 0, midYValue = 0, maxX = 0;
  final int timeSpan = 180; // Default to 6 months
  final String defaultCurrencyCode = 'EUR'; // Default currency

  CurrencyHistoryProvider() {
    fetchCurrencies();
  }

  Future<void> fetchCurrencies() async {
    try {
      var allCurrencies = await _mainRepository.getDailyCurrencies();
      coreCurrencies =
          allCurrencies.where((currency) => currency.isCore).toList();
      selectedCurrency = coreCurrencies.firstWhere(
        (currency) => currency.currencyCode == defaultCurrencyCode,
        orElse: () => coreCurrencies.first,
      );
      await loadCurrencyHistory();
      notifyListeners();
    } catch (e) {
      AppLogger.logError("Failed to fetch currencies", error: e);
      rethrow;
    }
  }

  Future<void> loadCurrencyHistory() async {
    if (selectedCurrency == null) {
      AppLogger.logError("Failed to load currency history");
      throw Exception('Selected currency is not set.');
    }

    selectedCurrency =
        await _mainRepository.getCurrencyHistory(selectedCurrency!);

    if (selectedCurrency!.history!.isNotEmpty) {
      filteredHistoryEntries = selectedCurrency!.history!;
      processData(days: timeSpan);
    } else {
      throw Exception('No history data available for the selected currency.');
    }

    notifyListeners();
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
    selectedValue = filteredHistoryEntries.isNotEmpty
        ? filteredHistoryEntries.last.buy.toStringAsFixed(2)
        : '';
    selectedDate = filteredHistoryEntries.isNotEmpty
        ? DateFormat('dd/MM/yyyy').format(filteredHistoryEntries.last.date)
        : '';
    maxYValue = maxDataValue + bufferValue;
    minYValue = minDataValue - bufferValue;
    midYValue = (maxYValue + minYValue) / 2;
    maxX = filteredHistoryEntries.length.toDouble() - 1;
    notifyListeners();
  }
}
