import 'package:flutter/material.dart';
import 'package:dinar_echange/data/models/currency_model.dart';
import 'package:dinar_echange/widgets/flag_container.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';

class CurrencyValueCard extends StatelessWidget {
  final Currency currency;

  const CurrencyValueCard({
    super.key,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 00),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCurrencyDetails(context),
            _buildRateColumn(context, AppLocalizations.of(context)!.buy,
                '${currency.buy}', Colors.green[800]!),
            _buildRateColumn(context, AppLocalizations.of(context)!.sell,
                '${currency.sell}', Colors.red[800]!),
          ],
        ),
      ),
    );
  }

  Widget _buildRateColumn(
      BuildContext context, String label, String rate, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end, // Right-align rate details
      children: [
        Text(
          label,
          style:
              Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
        ),
        Text(
          rate,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCurrencyDetails(BuildContext context) {
    return Row(
      children: [
        FlagContainer(
          imageUrl: currency.flag!,
          width: 50,
          height: 40,
          borderRadius: BorderRadius.circular(1),
        ),
        const SizedBox(width: 8), // Space between flag and text
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currency.currencyName!,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              currency.currencySymbol!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ],
    );
  }
}
