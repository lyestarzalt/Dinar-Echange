import 'package:flutter/material.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:dinar_watch/data/repositories/main_repository.dart';

class CurrencyListProvider with ChangeNotifier {
  List<Currency> _currencies = [];
  bool _isLoading = true;

  List<Currency> get currencies => _currencies;
  bool get isLoading => _isLoading;

  CurrencyListProvider() {
    _fetchCurrencies();
  }

  Future<void> _fetchCurrencies() async {
    try {
      _currencies = await MainRepository().getDailyCurrencies();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      //TODO Handle errors
      _isLoading = false;
      notifyListeners();
    }
  }

}
