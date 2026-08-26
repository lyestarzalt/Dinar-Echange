import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:dinar_echange/data/models/currency_model.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:dinar_echange/providers/admob_provider.dart';
import 'package:dinar_echange/providers/converter_provider.dart';
import 'package:dinar_echange/widgets/adbanner.dart';
import 'package:dinar_echange/widgets/convert/currency_input.dart';
import 'package:dinar_echange/widgets/convert/number_words.dart';

/// Two-input converter for a single currency pair. Foreign row on top,
/// DZD row on bottom — visual order swaps when the direction toggles.
class CurrencyConverterPage extends StatelessWidget {
  final String marketType;

  const CurrencyConverterPage({super.key, required this.marketType});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CurrencyConverterProvider>(context);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: _CurrencyAppBar(currency: provider.currency),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    children: [
                      _Converter(
                        provider: provider,
                        marketType: marketType,
                      ),
                      const SizedBox(height: 24),
                      if (!provider.isDZDtoCurrency)
                        NumberToWordsDisplay(
                          currency: provider.currency,
                          isDZDtoCurrency: !provider.isDZDtoCurrency,
                          numberController: provider.resultController,
                          provider: provider,
                        ),
                    ],
                  ),
                ),
              ),
              _BottomAd(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Converter extends StatelessWidget {
  final CurrencyConverterProvider provider;
  final String marketType;

  const _Converter({required this.provider, required this.marketType});

  @override
  Widget build(BuildContext context) {
    final foreignRow = buildCurrencyInput(
      controller: provider.isDZDtoCurrency
          ? provider.resultController
          : provider.amountController,
      inputController: provider.amountController,
      currencyCode: provider.currency.currencyCode,
      flag: provider.currency.flag,
      focusNode: provider.isDZDtoCurrency
          ? provider.resultFocusNode
          : provider.amountFocusNode,
      context: context,
    );

    final dzdRow = buildCurrencyInput(
      controller: provider.isDZDtoCurrency
          ? provider.amountController
          : provider.resultController,
      inputController: provider.amountController,
      currencyCode: 'DZD',
      flag: provider.currency.flag,
      focusNode: provider.isDZDtoCurrency
          ? provider.amountFocusNode
          : provider.resultFocusNode,
      context: context,
    );

    // When DZD→foreign, DZD sits on top (source you type in). When
    // foreign→DZD (default), the foreign row is on top. This keeps the
    // "you type here → you read there" reading direction stable.
    final top = provider.isDZDtoCurrency ? dzdRow : foreignRow;
    final bottom = provider.isDZDtoCurrency ? foreignRow : dzdRow;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Column(
        key: ValueKey(provider.isDZDtoCurrency),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          top,
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: _SwapButton(
              onTap: provider.toggleConversionDirection,
              marketType: marketType,
            ),
          ),
          const SizedBox(height: 8),
          bottom,
        ],
      ),
    );
  }
}

/// Small pill button that swaps the conversion direction. Replaces the
/// old FloatingActionButton — a screen-level FAB was overkill for a
/// button that lives inline between two inputs.
class _SwapButton extends StatelessWidget {
  final VoidCallback onTap;
  final String marketType;

  const _SwapButton({required this.onTap, required this.marketType});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    return Semantics(
      button: true,
      label: AppLocalizations.of(context)!.switch_tooltip,
      child: Material(
        color: scheme.primaryContainer,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: SizedBox(
            height: 44,
            width: 44,
            child: Icon(
              Icons.swap_vert,
              color: scheme.onPrimaryContainer,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

/// Themed app bar for the converter route: back button on the left,
/// currency code + name in the title area, buy/sell rate at the right.
/// Everything reads through Theme.of(context).textTheme instead of the
/// old hardcoded fontSize/bold combos.
class _CurrencyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Currency currency;

  const _CurrencyAppBar({required this.currency});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(currency.currencyCode, style: t.textTheme.titleLarge),
          if (currency.currencyName != null && currency.currencyName!.isNotEmpty)
            Text(
              currency.currencyName!,
              style: t.textTheme.labelMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      centerTitle: false,
      actions: [
        _RatePair(buy: currency.buy, sell: currency.sell),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _RatePair extends StatelessWidget {
  final double buy;
  final double sell;
  const _RatePair({required this.buy, required this.sell});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;

    String fmt(double v) =>
        v >= 100 ? v.round().toString() : v.toStringAsFixed(1);
    final l10n = AppLocalizations.of(context)!;

    Widget cell(String label, double v) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              label.toUpperCase(),
              style: t.textTheme.labelSmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 2),
            Text(
              fmt(v),
              style: t.textTheme.titleMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          cell(l10n.buy, buy),
          const SizedBox(width: 16),
          cell(l10n.sell, sell),
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
            border: Border(top: BorderSide(color: scheme.outlineVariant)),
          ),
          padding: const EdgeInsets.only(top: 8),
          child: const AdBannerWidget(),
        ),
      ),
    );
  }
}
