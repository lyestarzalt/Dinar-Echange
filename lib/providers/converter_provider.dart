import 'package:flutter/material.dart';
import 'package:dinar_echange/data/models/currency_model.dart';
import 'package:intl/intl.dart';
import 'package:dinar_echange/utils/logging.dart';

class CurrencyConverterProvider with ChangeNotifier {
  final Currency currency;
  final TextEditingController amountController;
  final TextEditingController resultController;
  final FocusNode amountFocusNode;
  final FocusNode resultFocusNode;
  bool _isDZDtoCurrency = false;
  bool _useCentimes = false;

  CurrencyConverterProvider(this.currency)
      : amountController = TextEditingController(text: "100"),
        resultController = TextEditingController(),
        amountFocusNode = FocusNode(),
        resultFocusNode = FocusNode() {
    _initializeConverter();
  }

  bool get isDZDtoCurrency => _isDZDtoCurrency;
  bool get useCentimes => _useCentimes;

  double get conversionRate =>
      _isDZDtoCurrency ? _getInverseRate() : currency.sell;

  void toggleConversionDirection() {
    _isDZDtoCurrency = !_isDZDtoCurrency;
    final amount = amountController.text;
    final result = resultController.text;
    amountController.text = result;
    resultController.text = amount;
    _updateConversion();
    notifyListeners();
  }

  void toggleCentimes() {
    _useCentimes = !_useCentimes;
    _updateConversion();
    notifyListeners();
  }

  void _initializeConverter() {
    AppLogger.logEvent(
        'converter_opened', {'currency_code': currency.currencyCode});
    amountController.addListener(_updateConversion);
    amountFocusNode.addListener(notifyListeners);
    resultFocusNode.addListener(notifyListeners);
    _updateConversion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      amountFocusNode.requestFocus();
    });
  }

  double _getInverseRate() => currency.buy > 0 ? 1 / currency.buy : 0;

  bool _isValidAmount(String input) {
    try {
      final cleanInput = input.replaceAll(',', '');
      final parsedAmount = double.tryParse(cleanInput);
      return parsedAmount != null &&
          parsedAmount > 0 &&
          !parsedAmount.isNaN &&
          !parsedAmount.isInfinite;
    } catch (e, stack) {
      AppLogger.logError('Input validation failed',
          error: e, stackTrace: stack);
      return false;
    }
  }

  void _updateConversion() {
    try {
      final inputAmount = amountController.text;
      if (inputAmount.isEmpty) {
        resultController.clear();
        return;
      }
      final cleanInput = inputAmount.replaceAll(',', '');
      if (!_isValidAmount(cleanInput)) {
        resultController.clear();
        return;
      }
      final amount = double.parse(cleanInput);
      final rate = conversionRate;
      final convertedAmount = amount * rate;
      resultController.text = _formatAmount(convertedAmount);
    } catch (e, stack) {
      AppLogger.logError('Conversion failed', error: e, stackTrace: stack);
      resultController.clear();
    } finally {
      notifyListeners();
    }
  }

  String _formatAmount(double amount) {
    return NumberFormat.currency(
            locale: 'en_US', decimalDigits: useCentimes ? 2 : 0, symbol: '')
        .format(amount);
  }

  void _swapControllerValues() {
    final tempAmount = amountController.text;
    amountController.text = resultController.text;
    resultController.text = tempAmount;
    final currentAmount = amountController.text;
    amountController.text = '';
    amountController.text = currentAmount;
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
