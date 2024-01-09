import 'package:flutter/material.dart';
import 'package:dinar_watch/models/currency.dart';

class CurrencyConverterProvider with ChangeNotifier {
  final Currency currency;
  TextEditingController amountController = TextEditingController();
  TextEditingController resultController = TextEditingController();
  FocusNode amountFocusNode = FocusNode();
  FocusNode resultFocusNode = FocusNode();
  bool isDZDtoCurrency = false; // Conversion direction flag

  CurrencyConverterProvider(this.currency) {
    amountController.addListener(convertCurrency);
    amountFocusNode.addListener(notifyListeners);
    resultFocusNode.addListener(notifyListeners);
  }

  void toggleConversionDirection() {
    isDZDtoCurrency = !isDZDtoCurrency;
    swapTextControllers();
    notifyListeners();
  }

  static double getRate(bool isDZDtoCurrency, Currency currency) {
    if (isDZDtoCurrency) {
      return currency.buy > 0 ? 1 / currency.buy : 0;
    } else {
      return currency.sell;
    }
  }

  void convertCurrency() {
    try {
      if (amountController.text.isEmpty) {
        resultController.clear();
      } else {
        double amount = double.tryParse(amountController.text) ?? 0.0;
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
