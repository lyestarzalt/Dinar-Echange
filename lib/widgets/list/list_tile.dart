import 'package:flutter/material.dart';
import 'package:dinar_echange/data/models/currency.dart';
import 'package:dinar_echange/widgets/flag_container.dart';

class CurrencyListItem extends StatelessWidget {
  final Currency currency;

  const CurrencyListItem({
    super.key,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    TextScaler textScaler = MediaQuery.textScalerOf(context);

    return Directionality(
      textDirection: TextDirection.ltr,
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
              softWrap: false,
              style: TextStyle(
                  fontSize: textScaler.scale(15),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 2.5), // We can control the list tile height with
              //this along side the Divider.
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    currency.buy.toStringAsFixed(2),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: textScaler.scale(25),
                      height: 2.5,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                Text(
                  " DZD",
                  style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: textScaler.scale(12),
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 2.5),
                ),
                const SizedBox(width: 15),
                Icon(
                  Icons.arrow_forward_ios,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  size: textScaler.scale(14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
