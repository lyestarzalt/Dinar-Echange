import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dinar_echange/data/models/currency_model.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:dinar_echange/theme/brand_colors.dart';
import 'package:dinar_echange/widgets/flag_container.dart';
import 'package:dinar_echange/widgets/list/animated_rate.dart';

/// The signature moment of the app: one featured currency, both its
/// parallel and official rates side by side, and the spread between
/// them tied together with a brass bracket. The dual-market gap is
/// what makes the dinar economy story readable at a glance.
class HeroCurrencyCard extends StatelessWidget {
  final Currency parallel;
  final Currency? official;

  const HeroCurrencyCard({
    super.key,
    required this.parallel,
    required this.official,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final brand = context.brand;
    final scheme = t.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final dateFmt = DateFormat('d MMM yy');

    // Spread = how much more the parallel market charges vs official.
    // Only computed when both prices are available and the official
    // price is a positive number.
    double? spreadPct;
    if (official != null && official!.buy > 0) {
      spreadPct = ((parallel.buy - official!.buy) / official!.buy) * 100;
    }

    return Container(
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
          _Header(currency: parallel, dateText: dateFmt.format(parallel.date)),
          const SizedBox(height: 22),
          _RateRow(
            label: l10n.parallel_market.toUpperCase(),
            value: parallel.buy,
            dotColor: brand.parallel,
          ),
          if (official != null) ...[
            _SpreadBracket(percent: spreadPct, color: brand.spread),
            _RateRow(
              label: l10n.official_market.toUpperCase(),
              value: official!.buy,
              dotColor: brand.official,
            ),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Currency currency;
  final String dateText;

  const _Header({required this.currency, required this.dateText});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _CircleFlag(imageUrl: currency.flag, size: 40),
        const SizedBox(width: 14),
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

class _RateRow extends StatelessWidget {
  final String label;
  final double value;
  final Color dotColor;

  const _RateRow({
    required this.label,
    required this.value,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              label,
              style: t.textTheme.labelSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        AnimatedRate(
          value: value,
          format: (v) =>
              v >= 100 ? v.round().toString() : v.toStringAsFixed(1),
          style: t.textTheme.displayLarge!,
          baseColor: scheme.onSurface,
          upColor: Colors.green.shade700,
          downColor: Colors.red.shade700,
        ),
      ],
    );
  }
}

/// Brass tie between the two market rows: two short vertical lines with
/// a small percentage badge floating between them. This is the visual
/// signature — the app is defined by the gap.
class _SpreadBracket extends StatelessWidget {
  final double? percent;
  final Color color;

  const _SpreadBracket({required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 18),
          Expanded(child: Container(height: 1, color: color.withValues(alpha: 0.4))),
          if (percent != null) ...[
            const SizedBox(width: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: color.withValues(alpha: 0.35)),
              ),
              child: Text(
                'SPREAD  ${percent!.isNegative ? '' : '+'}${percent!.toStringAsFixed(1)}%',
                style: t.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ] else
            const SizedBox(width: 12),
          Container(width: 60, height: 1, color: color.withValues(alpha: 0.4)),
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
