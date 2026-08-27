import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:dinar_echange/data/models/currency_model.dart';
import 'package:dinar_echange/widgets/flag_container.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:dinar_echange/widgets/list/animated_rate.dart';
import 'package:dinar_echange/widgets/rate_gestures.dart';

class CurrencyListItem extends StatelessWidget {
  final Currency currency;

  const CurrencyListItem({super.key, required this.currency});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final numberFmt = NumberFormat.decimalPattern();
    String format(double v) => v >= 100
        ? numberFmt.format(v.round())
        : v.toStringAsFixed(1);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Semantics(
        container: true,
        label:
            '${currency.currencyName ?? currency.currencyCode}, ${l10n.buy} ${format(currency.buy)}, ${l10n.sell} ${format(currency.sell)}',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              FlagContainer(
                imageUrl: currency.flag,
                width: 36,
                height: 26,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  currency.currencyCode,
                  style: t.textTheme.titleLarge,
                ),
              ),
              _RateColumn(
                value: currency.buy,
                label: l10n.buy,
                format: format,
                scheme: scheme,
                textTheme: t.textTheme,
              ),
              const SizedBox(width: 20),
              _RateColumn(
                value: currency.sell,
                label: l10n.sell,
                format: format,
                scheme: scheme,
                textTheme: t.textTheme,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RateColumn extends StatelessWidget {
  final double value;
  final String label;
  final String Function(double) format;
  final ColorScheme scheme;
  final TextTheme textTheme;

  const _RateColumn({
    required this.value,
    required this.label,
    required this.format,
    required this.scheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return CopyableRate(
      value: format(value),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedRate(
            value: value,
            format: format,
            style: textTheme.displaySmall!,
            baseColor: scheme.onSurface,
            upColor: Colors.green.shade600,
            downColor: Colors.red.shade600,
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
