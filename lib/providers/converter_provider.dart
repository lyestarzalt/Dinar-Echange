import 'package:flutter/material.dart';
import 'package:dinar_watch/data/models/currency.dart';

class ConvertProvider with ChangeNotifier {
  final Currency currency;
  TextEditingController amountController = TextEditingController();
  TextEditingController resultController = TextEditingController();
  FocusNode amountFocusNode = FocusNode();
  FocusNode resultFocusNode = FocusNode();
  bool isDZDtoCurrency = false; // Conversion direction flag

  ConvertProvider(this.currency) {
    amountController.addListener(convertCurrency);
    amountFocusNode.addListener(notifyListeners);
    resultFocusNode.addListener(notifyListeners);
  }
  bool _useCentimes = false;
  bool get useCentimes => _useCentimes;

  void toggleUseCentimes() {
    _useCentimes = !_useCentimes;
    notifyListeners();
  }

  void toggleConversionDirection() {
    isDZDtoCurrency = !isDZDtoCurrency;
    swapTextControllers();
    notifyListeners();
  }

  static double getRate(bool isDZDtoCurrency, Currency currency) {
    //TODO: revise this
    if (isDZDtoCurrency) {
      return currency.sell > 0 ? 1 / currency.sell : 0;
    } else {
      return currency.buy;
    }
  }

  void convertCurrency() {
    try {
      if (amountController.text.isEmpty) {
        resultController.clear();
      } else {
        String amountString =
            amountController.text.replaceAll(RegExp(r'[^0-9.]'), '');
        double amount = double.tryParse(amountString) ?? 0.0;
        double rate = getRate(isDZDtoCurrency, currency);
        double result = amount * rate;
        resultController.text = result.toStringAsFixed(2);
      }
      notifyListeners();
    } catch (e) {
      notifyListeners();
    }
  }

  void swapTextControllers() {
    String amountValue = amountController.text;
    amountController.text = resultController.text;
    resultController.text = amountValue;
  }

  @override
  void dispose() {
    amountController.dispose();
    resultController.dispose();
    amountFocusNode.dispose();
    resultFocusNode.dispose();
    super.dispose();
  }
}
