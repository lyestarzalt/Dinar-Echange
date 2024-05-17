import 'package:flutter/material.dart';
import 'package:dinar_echange/data/models/currency.dart';
import 'package:dinar_echange/services/preferences_service.dart';
import 'package:dinar_echange/data/repositories/main_repository.dart';

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
  }
  @override
  void dispose() {
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
  }

  Future<void> refreshData() async {
    allCurrencies = await MainRepository().getDailyCurrencies();
    notifyListeners();
  }

  Future<void> _loadSelectedCurrencies() async {
    List<String> savedCurrencyNames =
        await PreferencesService().getSelectedCurrencies();

    if (savedCurrencyNames.isEmpty) {
      // Initialize with core currencies if no saved preferences
      _selectedCurrencies =
          allCurrencies.where((currency) => currency.isCore).toList();
      await _saveCurrencyOrder(); // Save the initial order
    } else {
      // Load the currencies in the order they were saved
      _selectedCurrencies = savedCurrencyNames
          .map((code) => allCurrencies.firstWhere(
                (currency) => currency.currencyCode == code,
              ))
          .whereType<Currency>()
          .toList();
    }
    notifyListeners();
  }

  void updateSelectedCurrencies(List<Currency> newSelection) {
    _selectedCurrencies = newSelection;
    notifyListeners();
  }

  Future<void> saveSelectedCurrencies() async {
    List<String> currencyNames =
        _selectedCurrencies.map((c) => c.currencyCode).toList();
    await PreferencesService().setSelectedCurrencies(currencyNames);
  }

  void addOrRemoveCurrency(Currency currency, bool isSelected) async {
    if (isSelected) {
      _selectedCurrencies.add(currency);
      List<String> currencyNames =
          _selectedCurrencies.map((c) => c.currencyCode).toList();
      await PreferencesService().setSelectedCurrencies(currencyNames);
    } else {
      _selectedCurrencies.remove(currency);
      List<String> currencyNames =
          _selectedCurrencies.map((c) => c.currencyCode).toList();
      await PreferencesService().setSelectedCurrencies(currencyNames);
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
  }

  Future<void> _saveCurrencyOrder() async {
    final List<String> currencyOrder =
        _selectedCurrencies.map((currency) => currency.currencyCode).toList();
    await PreferencesService().setSelectedCurrencies(currencyOrder);
  }

  void filterCurrencies(String searchTerm) {
    searchTerm = searchTerm.toLowerCase();
    _filteredCurrencies = allCurrencies
        .where((currency) =>
            currency.currencyCode.toLowerCase().contains(searchTerm) ||
            (currency.currencyName?.toLowerCase().contains(searchTerm) ??
                false))
        .toList();
    notifyListeners();
  }
}
