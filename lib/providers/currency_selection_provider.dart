import 'package:flutter/material.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:dinar_watch/services/preferences_service.dart';
import 'package:dinar_watch/data/repositories/main_repository.dart';

class CurrencySelectionProvider with ChangeNotifier {
  List<Currency> _allCurrencies = [];
  List<Currency> _selectedCurrencies = [];
  List<Currency> _filteredCurrencies = [];
  TextEditingController searchController = TextEditingController();

  List<Currency> get selectedCurrencies => _selectedCurrencies;
  List<Currency> get filteredCurrencies => _filteredCurrencies;

  CurrencySelectionProvider() {
    _initializeCurrencies();

    searchController.addListener(_filterCurrencies);
  }
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeCurrencies() async {
    try {
      _allCurrencies = await MainRepository().getDailyCurrencies();
      _filteredCurrencies = List.from(
          _allCurrencies); // init the list for the add currecnies page
      await _loadSelectedCurrencies();
    } catch (e) {
    } finally {
      notifyListeners();
    }
  }

  void _filterCurrencies() {
    String searchTerm = searchController.text.toLowerCase();
    _filteredCurrencies = _allCurrencies
        .where((currency) =>
            currency.currencyCode.toLowerCase().contains(searchTerm) ||
            (currency.currencyName?.toLowerCase().contains(searchTerm) ??
                false))
        .toList();
    notifyListeners();
  }

  Future<void> _loadSelectedCurrencies() async {
    List<String> savedCurrencyNames =
        await PreferencesService().getSelectedCurrencies();

    if (savedCurrencyNames.isEmpty) {
      // Initialize with core currencies if no saved preferences
      _selectedCurrencies =
          _allCurrencies.where((currency) => currency.isCore).toList();
      await _saveCurrencyOrder(); // Save the initial order
    } else {
      // Load the currencies in the order they were saved
      _selectedCurrencies = savedCurrencyNames
          .map((code) => _allCurrencies.firstWhere(
                (currency) => currency.currencyCode == code,
              ))
          .whereType<Currency>()
          .toList();
    }
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

  void addOrRemoveCurrency(Currency currency, bool isSelected) {
    if (isSelected) {
      _selectedCurrencies.add(currency);
    } else {
      _selectedCurrencies.remove(currency);
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
    _filteredCurrencies = _allCurrencies
        .where((currency) =>
            currency.currencyCode.toLowerCase().contains(searchTerm) ||
            (currency.currencyName?.toLowerCase().contains(searchTerm) ??
                false))
        .toList();
    notifyListeners();
  }
}
