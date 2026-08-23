import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      rateFor(currency: currency, isDZDtoCurrency: _isDZDtoCurrency);

  // Rates follow the universal FX convention where `buy` is the exchanger's
  // BID (lower, what they pay to buy foreign from the customer) and `sell` is
  // their ASK (higher, what they charge to sell foreign to the customer).
  //  - Foreign → DZD: customer SELLS foreign → exchanger uses BID → `buy`.
  //  - DZD → foreign: customer BUYS foreign → exchanger uses ASK → `1/sell`.
  @visibleForTesting
  static double rateFor({
    required Currency currency,
    required bool isDZDtoCurrency,
  }) {
    if (isDZDtoCurrency) {
      return currency.sell > 0 ? 1 / currency.sell : 0;
    }
    return currency.buy;
  }

  void toggleConversionDirection() {
    HapticFeedback.selectionClick();
    _isDZDtoCurrency = !_isDZDtoCurrency;
    final amount = amountController.text;
    final result = resultController.text;
    amountController.text = result;
    resultController.text = amount;
    _updateConversion();
    notifyListeners();
  }

  void toggleCentimes() {
    HapticFeedback.selectionClick();
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

  @override
  void dispose() {
    amountController.dispose();
    resultController.dispose();
    amountFocusNode.dispose();
    resultFocusNode.dispose();
    super.dispose();
  }
}
