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
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Flag and Currency Code Group
            Row(
              children: [
                FlagContainer(
                  imageUrl: currency.flag,
                  width: 32,
                  height: 24,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(width: 12),
                Text(
                  currency.currencyCode,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Buy/Sell Values Group
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Buy Value
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currency.buy >= 100
                          ? currency.buy.toStringAsFixed(0)
                          : currency.buy.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.buy,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 24),

                // Sell Value
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currency.sell >= 100
                          ? currency.sell.toStringAsFixed(0)
                          : currency.sell.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.sell,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 8),

                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
