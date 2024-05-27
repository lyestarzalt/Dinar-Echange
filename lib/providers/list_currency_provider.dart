import 'package:flutter/material.dart';
import 'package:dinar_echange/data/models/currency.dart';
import 'package:dinar_echange/services/preferences_service.dart';
import 'package:dinar_echange/data/repositories/main_repository.dart';
import 'package:dinar_echange/utils/logging.dart';

class ListCurrencyProvider with ChangeNotifier {
  List<Currency> allCurrencies = [];
  List<Currency> _selectedCurrencies = [];
  List<Currency> _filteredCurrencies = [];
  TextEditingController searchController = TextEditingController();

  List<Currency> get selectedCurrencies => _selectedCurrencies;
  List<Currency> get filteredCurrencies => _filteredCurrencies;

  ListCurrencyProvider(List<Currency> currencies) {
    allCurrencies = currencies;
    _filteredCurrencies = allCurrencies;
    _loadSelectedCurrencies();
    searchController.addListener(_filterCurrencies);
    AppLogger.logInfo(
        "ListCurrencyProvider initialized with ${currencies.length} currencies.");
  }

  @override
  void dispose() {
    AppLogger.logDebug("Disposing ListCurrencyProvider.");
    searchController.dispose();
    super.dispose();
  }

  void _filterCurrencies() {
    String searchTerm = searchController.text.toLowerCase();
    _filteredCurrencies = allCurrencies
        .where((currency) =>
            currency.currencyCode.toLowerCase().contains(searchTerm) ||
            (currency.currencyName?.toLowerCase().contains(searchTerm) ??
                false))
        .toList();
    notifyListeners();
    AppLogger.logInfo("Filtered currencies based on search term: $searchTerm");
  }

  Future<void> refreshData() async {
    try {
      allCurrencies = await MainRepository().getDailyCurrencies();
      notifyListeners();
      AppLogger.logInfo("Currencies data refreshed.");
    } catch (e, stacktrace) {
      AppLogger.logError("Failed to refresh currency data",
          error: e, stackTrace: stacktrace);
    }
  }

  Future<void> _loadSelectedCurrencies() async {
    try {
      List<String> savedCurrencyNames =
          await PreferencesService().getSelectedCurrencies();
      if (savedCurrencyNames.isEmpty) {
        _selectedCurrencies =
            allCurrencies.where((currency) => currency.isCore).toList();
        await _saveCurrencyOrder();
        AppLogger.logInfo(
            "Initialized selected currencies with core currencies.");
      } else {
        // Load the currencies in the order they were saved
        _selectedCurrencies = savedCurrencyNames
            .map((code) => allCurrencies.firstWhere(
                  (currency) => currency.currencyCode == code,
                ))
            .whereType<Currency>()
            .toList();
        notifyListeners();
        AppLogger.logInfo("Loaded selected currencies from saved preferences.");
      }
    } catch (e, stacktrace) {
      AppLogger.logError("Failed to load selected currencies",
          error: e, stackTrace: stacktrace);
    }
  }

  void updateSelectedCurrencies(List<Currency> newSelection) {
    _selectedCurrencies = newSelection;
    notifyListeners();
    AppLogger.logInfo("Updated selected currencies.");
  }

  Future<void> saveSelectedCurrencies() async {
    try {
      List<String> currencyNames =
          _selectedCurrencies.map((c) => c.currencyCode).toList();
      await PreferencesService().setSelectedCurrencies(currencyNames);
      AppLogger.logInfo("Saved selected currencies.");
    } catch (e, stacktrace) {
      AppLogger.logError("Failed to save selected currencies",
          error: e, stackTrace: stacktrace);
    }
  }

  void addOrRemoveCurrency(Currency currency, bool isSelected) async {
    try {
      if (isSelected) {
        _selectedCurrencies.add(currency);
      } else {
        _selectedCurrencies.remove(currency);
      }
      List<String> currencyNames =
          _selectedCurrencies.map((c) => c.currencyCode).toList();
      await PreferencesService().setSelectedCurrencies(currencyNames);
      AppLogger.logCurrencySelection(currency.currencyCode, isSelected);
    } catch (e, stacktrace) {
      AppLogger.logError("Failed to add or remove currency",
          error: e, stackTrace: stacktrace);
    }
    notifyListeners();
  }

  void reorderCurrencies(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final Currency item = _selectedCurrencies.removeAt(oldIndex);
    _selectedCurrencies.insert(newIndex, item);
    _saveCurrencyOrder();
    notifyListeners();
    AppLogger.logInfo("Reordered currencies.");
  }

  Future<void> _saveCurrencyOrder() async {
    try {
      final List<String> currencyOrder =
          _selectedCurrencies.map((currency) => currency.currencyCode).toList();
      await PreferencesService().setSelectedCurrencies(currencyOrder);
      AppLogger.logInfo("Saved currency order.");
    } catch (e, stacktrace) {
      AppLogger.logError("Failed to save currency order",
          error: e, stackTrace: stacktrace);
    }
  }
}
