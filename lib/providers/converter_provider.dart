import 'package:flutter/material.dart';
import 'package:dinar_echange/data/models/currency.dart';
import 'package:intl/intl.dart';

import 'package:dinar_echange/utils/logging.dart';

class ConvertProvider with ChangeNotifier {
  final Currency currency;
  TextEditingController amountController = TextEditingController(text: "100");
  TextEditingController resultController = TextEditingController();
  FocusNode amountFocusNode = FocusNode();
  FocusNode resultFocusNode = FocusNode();
  bool isDZDtoCurrency = false; // Conversion direction flag

  ConvertProvider(this.currency) {
    AppLogger.logCurrencySelection(currency.currencyCode, true);
    AppLogger.trackScreenView('Converter_Screen');

    amountController.addListener(convertCurrency);
    amountFocusNode.addListener(notifyListeners);
    resultFocusNode.addListener(notifyListeners);
    // a callback to set the focus once the widget is built
    convertCurrency();

    // show the keypad after we open the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      amountFocusNode.requestFocus();
    });
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
      return currency.buy > 0 ? 1 / currency.buy : 0;
    } else {
      return currency.sell;
    }
  }

  bool validateInput(String input) {
    try {
      double? parsedAmount = double.tryParse(input);
      bool isValid = parsedAmount != null &&
          parsedAmount > 0 &&
          !parsedAmount.isNaN &&
          !parsedAmount.isInfinite;
      return isValid;
    } catch (e, stackTrace) {
      AppLogger.logError('Error validating input',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  void convertCurrency() {
    try {
      if (amountController.text.isEmpty) {
        resultController.clear();
      } else if (validateInput(amountController.text)) {
        double parsedAmount = double.parse(amountController.text);
        double rate = getRate(isDZDtoCurrency, currency);
        double result = parsedAmount * rate;
        String formattedResult =
            NumberFormat.currency(locale: 'en_US', decimalDigits: 2, symbol: '')
                .format(result);
        resultController.text = formattedResult;
      } else {
        resultController.clear();
      }
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.logError('Failed to convert currency',
          error: e, stackTrace: stackTrace);
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
