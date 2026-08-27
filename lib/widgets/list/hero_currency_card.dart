import 'package:flutter/material.dart';
import 'package:dinar_echange/data/models/currency_model.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:dinar_echange/theme/brand_colors.dart';
import 'package:dinar_echange/utils/formatters.dart';
import 'package:dinar_echange/widgets/flag_container.dart';
import 'package:dinar_echange/widgets/list/animated_rate.dart';
import 'package:dinar_echange/widgets/rate_gestures.dart';

/// Featured currency at the top of the main screen.
///
/// Layout, top to bottom:
///   1. flag + code · name .......... short date
///   2. big buy rate in DZD ......... trend badge (if history)
///   3. small "SELL 268" secondary line
///
/// currency.date is the day the rate was published (midnight, no
/// meaningful clock time), so it's rendered as a short date rather than
/// "HH:mm" which would just say "00:00".
class HeroCurrencyCard extends StatelessWidget {
  final Currency currency;

  const HeroCurrencyCard({super.key, required this.currency});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    final brand = context.brand;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final fmt = LocaleFormatters.of(locale);

    String formatRate(double v) => v >= 100
        ? fmt.number.format(v.round())
        : v.toStringAsFixed(1);
    final buyText = formatRate(currency.buy);
    final sellText = formatRate(currency.sell);

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

    final semanticLabel =
        '${currency.currencyName ?? currency.currencyCode}, ${l10n.buy} $buyText, ${l10n.sell} $sellText DZD'
        '${deltaPct != null ? ", ${wentUp ? "+" : ""}${deltaPct.toStringAsFixed(2)}%" : ''}';

    return RepaintBoundary(
      child: Semantics(
        container: true,
        label: semanticLabel,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderRow(currency: currency, dateText: fmt.MMMd.format(currency.date)),
              const SizedBox(height: 14),
              _BuyRow(
                currency: currency,
                buyText: buyText,
                delta: delta,
                deltaPct: deltaPct,
                brand: brand,
              ),
              const SizedBox(height: 8),
              _SellRow(sellText: sellText, sellLabel: l10n.sell),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final Currency currency;
  final String dateText;

  const _HeaderRow({required this.currency, required this.dateText});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FlagContainer(
          imageUrl: currency.flag,
          width: 40,
          height: 28,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
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
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        Text(dateText, style: t.textTheme.labelSmall),
      ],
    );
  }
}

class _BuyRow extends StatelessWidget {
  final Currency currency;
  final String buyText;
  final double? delta;
  final double? deltaPct;
  final BrandColors brand;

  const _BuyRow({
    required this.currency,
    required this.buyText,
    required this.delta,
    required this.deltaPct,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;

    String formatRate(double v) => v >= 100
        ? v.round().toString()
        : v.toStringAsFixed(1);

    return CopyableRate(
      value: buyText,
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
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('DZD', style: t.textTheme.labelSmall),
          ),
          const Spacer(),
          if (deltaPct != null) _TrendBadge(deltaPct: deltaPct!, brand: brand),
        ],
      ),
    );
  }
}

class _SellRow extends StatelessWidget {
  final String sellText;
  final String sellLabel;

  const _SellRow({required this.sellText, required this.sellLabel});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          sellLabel.toUpperCase(),
          style: t.textTheme.labelSmall
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(width: 10),
        CopyableRate(
          value: sellText,
          child: Text(
            sellText,
            style: t.textTheme.titleMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

/// Small brass pill showing the period change vs. earliest history
/// entry. Only rendered when history is loaded (rare in the list view
/// today; will always show up on screens that fetch history).
class _TrendBadge extends StatelessWidget {
  final double deltaPct;
  final BrandColors brand;

  const _TrendBadge({required this.deltaPct, required this.brand});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final wentUp = deltaPct >= 0;
    final color = wentUp ? Colors.green.shade700 : Colors.red.shade700;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            wentUp ? '↑' : '↓',
            style: t.textTheme.labelMedium?.copyWith(color: color),
          ),
          const SizedBox(width: 2),
          Text(
            '${wentUp ? '+' : ''}${deltaPct.toStringAsFixed(2)}%',
            style: t.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
