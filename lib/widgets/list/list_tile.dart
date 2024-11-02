import 'package:flutter/material.dart';
import 'package:dinar_echange/data/models/currency.dart';
import 'package:dinar_echange/widgets/flag_container.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';

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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FlagContainer(
              imageUrl: currency.flag,
              width: 50,
              height: 40,
              borderRadius: BorderRadius.circular(1),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                currency.currencyCode,
                softWrap: false,
                style: TextStyle(
                  fontSize: textScaler.scale(15),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.0,
                ),
              ),
            ),
            SizedBox(
              width: 60, // Fixed width
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    currency.buy.toStringAsFixed(2),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: textScaler.scale(15),
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.buy,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: textScaler.scale(10),
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    currency.sell.toStringAsFixed(2),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: textScaler.scale(15),
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.sell,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: textScaler.scale(10),
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              size: textScaler.scale(14),
            ),
          ],
        ),
      ),
    );
  }
}
