import 'package:flutter/material.dart';
import 'package:dinar_watch/widgets/flag_container.dart';
import 'package:dinar_watch/theme/theme_manager.dart';
import 'package:decimal/decimal.dart';
import 'package:dinar_watch/models/currency.dart';

String getConversionRateText(bool isDZDtoCurrency, Currency currency) {
  if (isDZDtoCurrency) {
    // Displaying conversion from DZD to the selected currency
    Decimal conversionRate = Decimal.parse((100 / currency.buy).toString());
    return '100 DZD = ${conversionRate.toStringAsFixed(2)} ${currency.currencyCode.toUpperCase()}';
  } else {
    // Displaying conversion from the selected currency to DZD
    Decimal conversionRate = Decimal.parse((currency.sell * 1).toString());
    return '1 ${currency.currencyCode.toUpperCase()} = ${conversionRate.toStringAsFixed(2)} DZD';
  }
}

Widget buildCurrencyInput(
     BuildContext context,
  TextEditingController amountController, // Add this argument
  TextEditingController controller,
  String currencyCode,
  String? flag,
  FocusNode focusNode,
    ) {
  bool isInputEnabled = controller == amountController;
  var cardTheme = ThemeManager.currencyInputCardTheme(context);

  // Determine border color based on theme brightness
  var themeBrightness = Theme.of(context).brightness;
  Color borderColor =
      themeBrightness == Brightness.dark ? Colors.white : Colors.black;
  borderColor = focusNode.hasFocus
      ? borderColor
      : borderColor.withOpacity(0.3); // Adjust opacity for unfocused state

  return Card(
    elevation: cardTheme.elevation,
    shape: RoundedRectangleBorder(
      borderRadius: (cardTheme.shape as RoundedRectangleBorder).borderRadius,
      side: BorderSide(
        color: borderColor,
        width: focusNode.hasFocus ? 2.0 : 1.0,
      ),
    ),
    margin: cardTheme.margin,
    color: cardTheme.color,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (currencyCode == 'DZD')
            Image.asset('assets/dz.png', width: 50, height: 40)
          else if (flag!.isNotEmpty)
            FlagContainer(
              imageUrl: flag,
              width: 50,
              height: 40,
              borderRadius: BorderRadius.circular(1),
            ),
          const SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              focusNode: focusNode,
              controller: controller,
              decoration:
                  ThemeManager.currencyInputDecoration(context, currencyCode),
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 0.0),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              enabled: isInputEnabled,
            ),
          ),
        ],
      ),
    ),
  );
}
