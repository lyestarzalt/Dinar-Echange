import 'package:dinar_echange/providers/graph_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dinar_echange/data/models/currency_model.dart';
import 'package:dinar_echange/widgets/graph/core_currency_menu.dart';
import 'package:dinar_echange/widgets/graph/time_span_buttons.dart';
import 'package:dinar_echange/widgets/graph/custom_line_graph.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:dinar_echange/utils/enums.dart';
import 'package:intl/intl.dart';
import 'package:dinar_echange/theme/brand_colors.dart';
import 'package:dinar_echange/widgets/flag_container.dart';
import 'package:dinar_echange/widgets/adbanner.dart';
import 'package:dinar_echange/widgets/error_message.dart';
import 'package:dinar_echange/widgets/skeletons.dart';
import 'package:dinar_echange/providers/admob_provider.dart';
import 'package:dinar_echange/providers/appinit_provider.dart';

/// The trends screen: one featured currency's history as a filled line
/// chart, framed by the hero rate above it and a stats strip below it.
/// The chart's brass under-fill is the visual signature that ties this
/// screen back to the design system.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppInitializationProvider>(
      builder: (context, initProvider, _) {
        final List<Currency> currencies = initProvider.currencies!;
        return ChangeNotifierProvider<GraphProvider>(
          create: (_) => GraphProvider(currencies),
          child: Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.trends_app_bar_title),
            ),
            body: Consumer<GraphProvider>(
              builder: (context, provider, _) {
                switch (provider.state.state) {
                  case LoadState.loading:
                    return const GraphSkeleton();
                  case LoadState.success:
                    return _Content(provider: provider);
                  case LoadState.error:
                    return ErrorMessage(
                      onRetry: () => provider.fetchCurrencies(currencies),
                    );
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  final GraphProvider provider;
  const _Content({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(provider: provider),
          const SizedBox(height: 20),
          _HeroRate(provider: provider),
          const SizedBox(height: 20),
          TimeSpanButtons(
            onTimeSpanSelected: provider.setDisplayPeriod,
          ),
          const SizedBox(height: 12),
          _Chart(provider: provider),
          const SizedBox(height: 20),
          _StatsStrip(provider: provider),
          const SizedBox(height: 24),
          _BottomAd(),
        ],
      ),
    );
  }
}

/// Tappable header — flag + code + name + chevron. Opens the currency
/// picker in-place instead of via a floating action button, so the
/// currency you're viewing is also the currency you'd change.
class _Header extends StatelessWidget {
  final GraphProvider provider;
  const _Header({required this.provider});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    final currency = provider.selectedCurrency!;
    return InkWell(
      onTap: () => _openPicker(context, provider),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
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
            Icon(Icons.expand_more, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  void _openPicker(BuildContext context, GraphProvider provider) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => CurrencyMenu(
        coreCurrencies: provider.coreCurrencies,
        onCurrencySelected: (Currency selected) {
          provider.selectedCurrency = selected;
          provider.loadCurrencyHistory();
        },
        parentContext: context,
      ),
    ));
  }
}

class _HeroRate extends StatelessWidget {
  final GraphProvider provider;
  const _HeroRate({required this.provider});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.yMMMMd(locale);
    final numberFmt = NumberFormat.decimalPattern(locale);
    final numberFmt2 = NumberFormat.decimalPatternDigits(
        locale: locale, decimalDigits: 2);
    final wentUp = provider.periodChange >= 0;
    final trendColor = wentUp ? Colors.green.shade700 : Colors.red.shade700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<String>(
          valueListenable: provider.selectedExchangeRate,
          builder: (context, valueString, _) {
            final value = double.tryParse(valueString) ?? 0;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value >= 100
                      ? numberFmt.format(value.round())
                      : numberFmt2.format(value),
                  style: t.textTheme.displayLarge,
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text('DZD', style: t.textTheme.labelSmall),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              wentUp ? '↑' : '↓',
              style: t.textTheme.titleMedium?.copyWith(color: trendColor),
            ),
            const SizedBox(width: 4),
            Text(
              '${wentUp ? '+' : ''}${numberFmt2.format(provider.periodChange)} '
              '(${wentUp ? '+' : ''}${provider.periodChangePct.toStringAsFixed(2)}%)',
              style: t.textTheme.labelMedium?.copyWith(color: trendColor),
            ),
            const SizedBox(width: 12),
            ValueListenableBuilder<DateTime>(
              valueListenable: provider.selectedDate,
              builder: (context, date, _) => Text(
                dateFmt.format(date),
                style: t.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Chart extends StatelessWidget {
  final GraphProvider provider;
  const _Chart({required this.provider});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brand = context.brand;
    return SizedBox(
      height: 230,
      child: CustomLineGraph(
        dataPoints: provider.historicalData.map((e) => e.buy).toList(),
        dates: provider.historicalData.map((e) => e.date).toList(),
        gridColor: scheme.outlineVariant,
        labelColor: scheme.onSurface,
        upTrendColor: Colors.green.shade700,
        downTrendColor: Colors.red.shade700,
        fillColor: brand.spread,
        showBottomLabels: false,
        maxValue: provider.maxExchangeRate,
        minValue: provider.minExchangeRate,
        midValue: provider.averageExchangeRate,
        onPointSelected: (index, date, value) =>
            provider.updateSelectedPoint(index),
      ),
    );
  }
}

/// Four-column footer strip: high, low, average, change over the current
/// display period. Uses Unicode symbols instead of English words so it
/// reads in every locale without an extra i18n round-trip.
class _StatsStrip extends StatelessWidget {
  final GraphProvider provider;
  const _StatsStrip({required this.provider});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final fmt = NumberFormat.decimalPatternDigits(
        locale: locale, decimalDigits: 2);
    final wentUp = provider.periodChange >= 0;
    final trendColor = wentUp ? Colors.green.shade700 : Colors.red.shade700;

    Widget stat(String glyph, String value, {Color? valueColor}) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(glyph,
                style: t.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: 14,
                  letterSpacing: 0,
                )),
            const SizedBox(height: 4),
            Text(
              value,
              style: t.textTheme.titleMedium?.copyWith(
                color: valueColor ?? scheme.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          stat('▲', fmt.format(provider.periodHigh)),
          stat('▼', fmt.format(provider.periodLow)),
          stat('─', fmt.format(provider.periodAvg)),
          stat(
            wentUp ? '↑' : '↓',
            '${wentUp ? '+' : ''}${fmt.format(provider.periodChange)}',
            valueColor: trendColor,
          ),
        ],
      ),
    );
  }
}

class _BottomAd extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ChangeNotifierProvider<AdProvider>(
      create: (_) => AdProvider(),
      child: Consumer<AdProvider>(
        builder: (context, adProvider, _) => Container(
          constraints: const BoxConstraints(minHeight: 60),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: scheme.outlineVariant),
            ),
          ),
          padding: const EdgeInsets.only(top: 8),
          child: const AdBannerWidget(),
        ),
      ),
    );
  }
}
