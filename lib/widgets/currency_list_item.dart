import 'package:flutter/material.dart';
import 'package:dinar_watch/theme/theme_manager.dart';
import 'package:dinar_watch/data/models/currency.dart';
import 'package:dinar_watch/widgets/flag_container.dart';
import 'dart:ui' as ui;

class CurrencyListItem extends StatelessWidget {
  final Currency currency;

  const CurrencyListItem({
    super.key,
    required this.currency,
  });

  String _formatCurrencyValue(double value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Column(
        children: [
          ListTile(
            leading: FlagContainer(
              imageUrl: currency.flag,
              width: 50,
              height: 40,
              borderRadius: BorderRadius.circular(1),
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
                  width: 80, // Width of the container for the currency values
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
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
          const Divider(height: 1)
        ],
      ),
    );
  }
}
