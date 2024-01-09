import 'package:flutter/material.dart';
import 'package:dinar_watch/data/models/currency.dart';
import 'package:dinar_watch/data/repositories/main_repository.dart';
import 'package:dinar_watch/data/models/currency_history.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

class CurrencyHistoryProvider with ChangeNotifier {
  final MainRepository _mainRepository = MainRepository();
  List<Currency> coreCurrencies = [];
  Currency? selectedCurrency;
  List<CurrencyHistoryEntry> filteredHistoryEntries = [];
  int touchedIndex = -1;
  String selectedValue = '';
  String selectedDate = '';
  double maxYValue = 0, minYValue = 0, midYValue = 0, maxX = 0;
  final int timeSpan = 30; // Default to 1 month
  final String defaultCurrencyCode = 'EUR'; // Default currency

  CurrencyHistoryProvider() {
    fetchCurrencies();
  }

  Future<List<Currency>> fetchCurrencies() async {
    try {
      var allCurrencies = await _mainRepository.getDailyCurrencies();
      coreCurrencies =
          allCurrencies.where((currency) => currency.isCore).toList();
      selectedCurrency = coreCurrencies.firstWhere(
        (currency) => currency.currencyCode == defaultCurrencyCode,
        orElse: () => coreCurrencies.first,
      );
      await loadCurrencyHistory();
      return coreCurrencies; // Return the filtered core currencies
    } catch (e) {
      // Handle exception, maybe log it or set an error message
      return []; // Return an empty list in case of an error
    }
  }

  Future<void> loadCurrencyHistory() async {
    if (selectedCurrency == null) {
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

  void processData({int days = 30}) {
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
  }
}
