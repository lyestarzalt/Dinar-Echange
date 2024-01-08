import 'package:flutter/material.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:dinar_watch/utils/finance_utils.dart';
import 'package:decimal/decimal.dart';

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

  String getConversionRateText() {
    if (isDZDtoCurrency) {
      Decimal conversionRate = Decimal.parse((100 / currency.buy).toString());
      return '100 DZD = ${conversionRate.toStringAsFixed(2)} ${currency.currencyCode.toUpperCase()}';
    } else {
      Decimal conversionRate = Decimal.parse((currency.sell * 1).toString());
      return '1 ${currency.currencyCode.toUpperCase()} = ${conversionRate.toStringAsFixed(2)} DZD';
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    resultController.dispose();
    amountFocusNode.dispose();
    resultFocusNode.dispose();
    super.dispose();
  }

  void onAmountChanged() {
    if (amountController.text.isEmpty) {
      resultController.text = '';
      notifyListeners();
      return;
    }

    double rate = isDZDtoCurrency ? 1 / currency.sell : currency.buy;
    double amount = double.tryParse(amountController.text) ?? 0.0;
    double result = amount * rate;

    resultController.text = result.toStringAsFixed(2);
    notifyListeners();
  }

  void convertCurrency() {
    if (amountController.text.isEmpty) {
      resultController.clear();
      notifyListeners();
      return;
    }

    double amount = double.tryParse(amountController.text) ?? 0.0;
    String convertedAmount = FinanceUtils.convertAmount(amount,
        isDZDtoCurrency ? currency.buy : currency.sell, isDZDtoCurrency);

    resultController.text = convertedAmount;
    notifyListeners();
  }
  void toggleConversionDirection() {
    isDZDtoCurrency = !isDZDtoCurrency;
    String amountValue = amountController.text;
    String resultValue = resultController.text;
    amountController.text = resultValue;
    resultController.text = amountValue;
    notifyListeners();
  }
}
