import 'package:flutter/material.dart';
import 'package:dinar_watch/theme_manager.dart';

Widget buildCurrencyInput(TextEditingController controller, String currencyCode,
    BuildContext context) {
  var cardTheme = ThemeManager.currencyInputCardTheme(context);
  return Card(
    elevation: cardTheme.elevation,
    shape: cardTheme.shape,
    margin: cardTheme.margin,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          const SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              controller: controller,
              decoration:
                  ThemeManager.currencyInputDecoration(context, currencyCode),
              style: TextStyle(
                fontSize: 24.0,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.left,
              enabled: true,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildConversionRateText(
    String conversionRateText, BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(
      vertical: 12,
      horizontal: 20,
    ),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceVariant,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      conversionRateText,
      style: ThemeManager.moneyNumberStyle(context),
    ),
  );
}
