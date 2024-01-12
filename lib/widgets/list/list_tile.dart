import 'package:flutter/material.dart';
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
    return value.toStringAsFixed(2);
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
            title: Text(
              currency.currencyCode,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 3.0),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 80, // Width of the container for the currency values
                  child: Text(
                    _formatCurrencyValue(currency.buy), // Buy value
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center, // Align text to the left
                  ),
                ),
                Text(
                  " DZD", // Currency unit
                  style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 3.0),
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
