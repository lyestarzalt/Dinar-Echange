import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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

class InputFormatter extends TextInputFormatter {
  final BuildContext context;

  InputFormatter(this.context);
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String newText = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (newText.isEmpty) {
      return newValue;
    }

    double value = double.tryParse(newText) ?? 0;
    newText = NumberFormat.currency(
      decimalDigits: 2,
      symbol: '',
      locale: Localizations.localeOf(context).toString(),
    ).format(value / 100);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
