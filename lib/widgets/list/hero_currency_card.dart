import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:dinar_echange/data/models/currency_model.dart';
import 'package:dinar_echange/widgets/flag_container.dart';
import 'package:dinar_echange/widgets/list/animated_rate.dart';

/// Featured-currency card shown at the top of the currencies list.
/// Uses the largest type in the app to make the app's core value —
/// "1 EUR = X DZD" — the visual center of the screen.
class HeroCurrencyCard extends StatelessWidget {
  final Currency currency;

  const HeroCurrencyCard({super.key, required this.currency});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    final dateFmt = DateFormat.yMMMd();
    final numberFmt = NumberFormat.currency(
      locale: 'en_US',
      decimalDigits: currency.buy >= 100 ? 0 : 2,
      symbol: '',
    );

    // Delta vs the earliest available history entry when history is loaded;
    // silent when it isn't (list view doesn't eagerly fetch history).
    double? delta;
    double? deltaPct;
    if (currency.history != null && currency.history!.isNotEmpty) {
      final first = currency.history!.first.buy;
      if (first > 0) {
        delta = currency.buy - first;
        deltaPct = (delta / first) * 100;
      }
    }
    final wentUp = (delta ?? 0) >= 0;
    final trendColor = wentUp ? Colors.green.shade600 : Colors.red.shade600;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CircleFlag(imageUrl: currency.flag, size: 40),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(currency.currencyCode, style: t.textTheme.titleLarge),
                  if (currency.currencyName != null &&
                      currency.currencyName!.isNotEmpty)
                    Text(
                      currency.currencyName!,
                      style: t.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                dateFmt.format(currency.date),
                style: t.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AnimatedRate(
                value: currency.buy,
                format: numberFmt.format,
                style: t.textTheme.displayLarge!,
                baseColor: scheme.onSurface,
                upColor: Colors.green.shade600,
                downColor: Colors.red.shade600,
                textAlign: TextAlign.left,
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'DZD',
                  style: t.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          if (delta != null && deltaPct != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  wentUp
                      ? PhosphorIconsBold.trendUp
                      : PhosphorIconsBold.trendDown,
                  size: 16,
                  color: trendColor,
                ),
                const SizedBox(width: 6),
                Text(
                  '${wentUp ? '+' : ''}${delta.toStringAsFixed(2)} (${deltaPct.toStringAsFixed(2)}%)',
                  style: t.textTheme.labelMedium?.copyWith(color: trendColor),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CircleFlag extends StatelessWidget {
  final String? imageUrl;
  final double size;
  const _CircleFlag({required this.imageUrl, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: scheme.outlineVariant, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: FittedBox(
        fit: BoxFit.cover,
        child: FlagContainer(
          imageUrl: imageUrl,
          width: size,
          height: size,
          borderRadius: BorderRadius.circular(size / 2),
        ),
      ),
    );
  }
}
