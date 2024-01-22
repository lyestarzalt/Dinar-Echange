import 'package:flutter/services.dart';

class InputFormatter extends TextInputFormatter {
  static const double _maxValue = 1000000000000; // 1 trillion

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Allow digits and a single decimal point
    String newText = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');
    if (newText.isEmpty) {
      return newValue;
    }

    // Check for more than one decimal point
    if (newText.indexOf('.') != newText.lastIndexOf('.')) {
      return oldValue;
    }

    // Parsing the number to ensure it's within the limit
    double value = double.tryParse(newText) ?? 0;
    if (value > _maxValue) {
      return oldValue; // If value exceeds the limit, revert to old value
    }

    return newValue.copyWith(
      text: newText,
      selection: newValue.selection, // Maintain the existing cursor position
    );
  }
}
