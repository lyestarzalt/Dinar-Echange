import 'package:flutter/services.dart';

class InputFormatter extends TextInputFormatter {
  static const double _maxValue = 1000000000000; // 1 trillion

  static List<TextInputFormatter> getFormatters() {
    return [
      InputFormatter(),
      FilteringTextInputFormatter.deny(RegExp('-')), // Prevent minus sign
      FilteringTextInputFormatter.allow(
          RegExp(r'[0-9.]')), // Only numbers and decimal
    ];
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Handle empty input
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove any non-digit and non-decimal characters
    String newText = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');
    if (newText.isEmpty) {
      return oldValue;
    }

    // Handle multiple decimal points
    if (newText.indexOf('.') != newText.lastIndexOf('.')) {
      return oldValue;
    }

    // Prevent more than 2 decimal places
    if (newText.contains('.')) {
      List<String> parts = newText.split('.');
      if (parts.length > 1 && parts[1].length > 2) {
        return oldValue;
      }
    }

    // Check value limits
    double? value = double.tryParse(newText);
    if (value == null || value > _maxValue) {
      return oldValue;
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
