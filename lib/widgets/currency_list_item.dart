// widgets/currency_list_item.dart

import 'package:flutter/material.dart';
import 'package:dinar_watch/theme_manager.dart';
import '../models/currency.dart';
import 'package:dinar_watch/pages/conversion_page.dart';
class CurrencyListItem extends StatelessWidget {
  final Currency currency;

  const CurrencyListItem({
    Key? key,
    required this.currency,
  }) : super(key: key);

  String _formatCurrencyValue(double value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        // Navigate to CurrencyConverterPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CurrencyConverterPage(currency: currency),
          ),
        );
      },
      leading: Container(
        width: 40,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            currency.currencyCode.substring(0, 2),
            style: ThemeManager.currencyCodeStyle(context),
          ),
        ),
      ),
      title: Hero(
        tag: 'hero_currency_${currency.currencyCode}',
        child: Material(
          color: Colors.transparent,
          child: Text(
            currency.currencyCode,
            style: ThemeManager.currencyCodeStyle(context),
          ),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 70, // Width of the container for the currency values
            child: Text(
              _formatCurrencyValue(currency.buy), // Buy value
              style: ThemeManager.moneyNumberStyle(context),
              textAlign: TextAlign.left, // Align text to the left
            ),
          ),
          Text(
            " DZD", // Currency unit
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 15), // Space between DZD and arrow icon
          Icon(
            Icons.arrow_forward_ios,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            size: 16,
          ),
        ],
      ),
    );
  }
}
