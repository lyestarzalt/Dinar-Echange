import 'package:flutter/services.dart';

class MaxNumberInputFormatter extends TextInputFormatter {
  final double max;

  MaxNumberInputFormatter(this.max);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final double? value = double.tryParse(newValue.text);
    if (value != null && value > max) {
      return oldValue;
    }
    return newValue;
  }
}
