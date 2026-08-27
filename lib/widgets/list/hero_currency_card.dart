import 'package:flutter/material.dart';
import 'package:dinar_echange/data/models/currency_model.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:dinar_echange/utils/formatters.dart';
import 'package:dinar_echange/widgets/flag_container.dart';
import 'package:dinar_echange/widgets/list/animated_rate.dart';
import 'package:dinar_echange/widgets/rate_gestures.dart';
import 'package:dinar_echange/widgets/relative_time.dart';

/// Featured currency at the top of the main screen. One big number —
/// today's parallel-market buy rate — plus a delta vs. the earliest
/// available history when we have it. Long-press the value to copy.
class HeroCurrencyCard extends StatelessWidget {
  final Currency currency;

  const HeroCurrencyCard({super.key, required this.currency});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final numberFmt = LocaleFormatters.of(locale).number;

    // Delta vs. earliest history entry when history is loaded.
    double? delta;
    double? deltaPct;
    if (currency.history != null && currency.history!.length > 1) {
      final earlier = currency.history!.first.buy;
      if (earlier > 0) {
        delta = currency.buy - earlier;
        deltaPct = (delta / earlier) * 100;
      }
    }
    final wentUp = (delta ?? 0) >= 0;
    final trendColor = wentUp ? Colors.green.shade700 : Colors.red.shade700;

    String formatRate(double v) => v >= 100
        ? numberFmt.format(v.round())
        : v.toStringAsFixed(1);
    final valueForCopy = formatRate(currency.buy);
    final semanticLabel =
        '${currency.currencyName ?? currency.currencyCode}, $valueForCopy DZD'
        '${delta != null && deltaPct != null ? ", ${wentUp ? l10n.buy : l10n.sell} ${deltaPct.abs().toStringAsFixed(2)}%" : ''}';

    return RepaintBoundary(
      child: Semantics(
      container: true,
      label: semanticLabel,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FlagContainer(
                  imageUrl: currency.flag,
                  width: 44,
                  height: 32,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currency.currencyCode,
                          style: t.textTheme.titleLarge),
                      if (currency.currencyName != null &&
                          currency.currencyName!.isNotEmpty)
                        Text(
                          currency.currencyName!,
                          style: t.textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                RelativeTime(
                  dateTime: currency.date,
                  style: t.textTheme.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: 20),
            CopyableRate(
              value: valueForCopy,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  AnimatedRate(
                    value: currency.buy,
                    format: formatRate,
                    style: t.textTheme.displayLarge!,
                    baseColor: scheme.onSurface,
                    upColor: Colors.green.shade700,
                    downColor: Colors.red.shade700,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('DZD', style: t.textTheme.labelSmall),
                  ),
                ],
              ),
            ),
            if (delta != null && deltaPct != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    wentUp ? '↑' : '↓',
                    style:
                        t.textTheme.titleMedium?.copyWith(color: trendColor),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${wentUp ? '+' : ''}${delta.toStringAsFixed(2)} (${deltaPct.toStringAsFixed(2)}%)',
                    style:
                        t.textTheme.labelMedium?.copyWith(color: trendColor),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ),
    );
  }
}
