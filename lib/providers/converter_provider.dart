import 'package:flutter/material.dart';
import 'package:dinar_watch/data/models/currency.dart';
import 'package:intl/intl.dart';

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
        double amount = double.tryParse(amountController.text) ?? 0.0;
        double rate = getRate(isDZDtoCurrency, currency);
        double result = amount * rate;

        String formattedResult =
            NumberFormat.currency(locale: 'en_US', decimalDigits: 2, symbol: '')
                .format(result);

        resultController.text = formattedResult;
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
