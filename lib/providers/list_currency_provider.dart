import 'package:flutter/material.dart';
import 'package:dinar_echange/data/models/currency_model.dart';
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
  String marketType; // 'official' or 'alternative'

  ListCurrencyProvider({
    required List<Currency> currencies,
    required this.marketType,
  }) {
    allCurrencies = currencies;
    _filteredCurrencies = allCurrencies;
    _loadSelectedCurrencies();
    searchController.addListener(_filterCurrencies);
    AppLogger.logInfo(
        "ListCurrencyProvider initialized with ${currencies.length} currencies.");
    notifyListeners();
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
      AppLogger.logInfo("$marketType Currencies data refreshed.");
    } catch (e, stacktrace) {
      AppLogger.logError("Failed to refresh currency data",
          error: e, stackTrace: stacktrace);
    }
  }

  Future<void> _loadSelectedCurrencies() async {
    try {
      List<String> savedCurrencyNames =
          await PreferencesService().getSelectedCurrencies(marketType);
      if (savedCurrencyNames.isEmpty && allCurrencies.isNotEmpty) {
        _selectedCurrencies =
            allCurrencies.where((currency) => currency.isCore).toList();
        await _saveCurrencyOrder();
      } else if (savedCurrencyNames.isNotEmpty) {
        _selectedCurrencies = savedCurrencyNames
            .map((code) => allCurrencies.firstWhere(
                  (currency) => currency.currencyCode == code,
                ))
            .whereType<Currency>()
            .toList();
        AppLogger.logInfo(
            "$marketType Loaded selected currencies from saved preferences.");
      } else {
        AppLogger.logDebug(
            "$marketType No saved currencies and allCurrencies is empty.");
      }
    } catch (e, stacktrace) {
      AppLogger.logError("$marketType Failed to load selected currencies",
          error: e, stackTrace: stacktrace);
    } finally {
      notifyListeners(); // Ensure UI is always updated after attempting to load currencies
    }
  }

  void updateSelectedCurrencies(List<Currency> newSelection) {
    _selectedCurrencies = newSelection;
    notifyListeners();
    AppLogger.logInfo("$marketType Updated selected currencies.");
  }

  Future<void> saveSelectedCurrencies() async {
    try {
      List<String> currencyNames =
          _selectedCurrencies.map((c) => c.currencyCode).toList();
      await PreferencesService()
          .setSelectedCurrencies(marketType, currencyNames);
      logSelectedCurrenciesSummary();

      AppLogger.logInfo("$marketType Saved selected currencies.");
    } catch (e, stacktrace) {
      AppLogger.logError("$marketType Failed to save selected currencies",
          error: e, stackTrace: stacktrace);
    }
  }

  void addOrRemoveCurrency(Currency currency, bool isSelected) async {
    try {
      if (isSelected) {
        if (!_selectedCurrencies.contains(currency)) {
          _selectedCurrencies.insert(0, currency);
        }
      } else {
        _selectedCurrencies.remove(currency);
      }
      List<String> currencyNames =
          _selectedCurrencies.map((c) => c.currencyCode).toList();
      await PreferencesService()
          .setSelectedCurrencies(marketType, currencyNames);
    } catch (e, stacktrace) {
      AppLogger.logError("$marketType Failed to add or remove currency",
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
    AppLogger.logInfo("$marketType Reordered currencies.");
  }

  Future<void> _saveCurrencyOrder() async {
    try {
      final List<String> currencyOrder =
          _selectedCurrencies.map((currency) => currency.currencyCode).toList();
      await PreferencesService()
          .setSelectedCurrencies(marketType, currencyOrder);
      AppLogger.logInfo("$marketType Saved currency order.");
    } catch (e, stacktrace) {
      AppLogger.logError("$marketType Failed to save currency order",
          error: e, stackTrace: stacktrace);
    }
  }

  void logSelectedCurrenciesSummary() {
    List<String> currencyCodes =
        _selectedCurrencies.map((c) => c.currencyCode).toList();
    AppLogger.logEvent('$marketType selected_currencies_updated',
        {'selected_currencies': currencyCodes.join(', ')});
  }

  DateTime getFormattedDate() {
    if (allCurrencies.isNotEmpty) {
      DateTime firstCurrencyDate = allCurrencies[0].date;
      return firstCurrencyDate;
    } else {
      return DateTime.fromMicrosecondsSinceEpoch(0);
    }
  }
}
