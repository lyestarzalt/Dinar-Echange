import 'package:dinar_watch/data/models/currency.dart';
import 'package:dinar_watch/services/preferences_service.dart';

class CurrencyService {
  final PreferencesService _preferencesService = PreferencesService();
  final Future<List<Currency>> _currenciesFuture;
  List<Currency> _selectedCurrencies = [];

  CurrencyService(this._currenciesFuture);

  Future<List<Currency>> loadSelectedCurrencies() async {
    List<Currency> allCurrencies = await _currenciesFuture;
    List<String> savedCurrencyNames =
        await _preferencesService.getSelectedCurrencies();
    if (savedCurrencyNames.isEmpty) {
      _selectedCurrencies =
          allCurrencies.where((currency) => currency.isCore).toList();
    } else {
      _selectedCurrencies = savedCurrencyNames
          .map((code) => allCurrencies
              .firstWhere((currency) => currency.currencyCode == code))
          .toList();
    }


    return _selectedCurrencies;
  }

  Future<void> saveCurrencyOrder() async {
    final List<String> currencyOrder =
        _selectedCurrencies.map((currency) => currency.currencyCode).toList();

    await _preferencesService.setSelectedCurrencies(currencyOrder);
  }

  void reorderCurrencies(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final Currency item = _selectedCurrencies.removeAt(oldIndex);
    _selectedCurrencies.insert(newIndex, item);
  }

  Future<List<Currency>> addCurrency(List<Currency> newCurrencies) async {
    _selectedCurrencies.addAll(newCurrencies);
    await saveCurrencyOrder();
    return _selectedCurrencies;
  }

}
