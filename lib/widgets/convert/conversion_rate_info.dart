import 'package:flutter/material.dart';
import 'package:dinar_watch/data/models/currency.dart'; 

class ConversionRateInfo extends StatelessWidget {
  final Currency currency;
  final bool isDZDtoCurrency;

  const ConversionRateInfo({
    super.key,
    required this.currency,
    required this.isDZDtoCurrency,
  });

  @override
  Widget build(BuildContext context) {
    String conversionRateText = _buildConversionRateText();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      constraints: BoxConstraints(
        minHeight: 50,
        maxWidth: MediaQuery.of(context).size.width - 32,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      ),
      child: Center(
        child: Text(
          conversionRateText,
          style:TextStyle(
      fontFamily: 'Courier',
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: Theme.of(context).colorScheme.onSurface,
    ),
        ),
      ),
    );
  }

String _buildConversionRateText() {
    if (isDZDtoCurrency) {
      double conversionRate = 100 / currency.buy;
      return '100 DZD = ${conversionRate.toStringAsFixed(2)} ${currency.currencyCode.toUpperCase()}';
    } else {
      double conversionRate = currency.sell * 1;
      return '1 ${currency.currencyCode.toUpperCase()} = ${conversionRate.toStringAsFixed(2)} DZD';
    }
  }

}
