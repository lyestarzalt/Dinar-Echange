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
  static const _rowHeight = 84.0;
  static const _gap = 12.0;
  static const _swapSize = 44.0;

  final CurrencyConverterProvider provider;
  final String marketType;

  const _Converter({required this.provider, required this.marketType});

  @override
  Widget build(BuildContext context) {
    // Two rows keep their identity (foreign stays foreign, DZD stays
    // DZD). Only their vertical position swaps when the direction
    // toggles — the "you type on top, you read on bottom" reading
    // relationship is preserved by AnimatedPositioned sliding them past
    // each other. Layout math is fixed (row heights are known), so no
    // MediaQuery.size dependency and it works at every screen size.
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

    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final duration =
        reducedMotion ? Duration.zero : const Duration(milliseconds: 320);

    final totalHeight = _rowHeight * 2 + _gap * 2 + _swapSize;
    final topPos = 0.0;
    final bottomPos = _rowHeight + _gap * 2 + _swapSize;
    final swapPos = _rowHeight + _gap;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        children: [
          // Foreign row: top when foreign→DZD, bottom when DZD→foreign.
          AnimatedPositioned(
            duration: duration,
            curve: Curves.easeInOutCubic,
            top: provider.isDZDtoCurrency ? bottomPos : topPos,
            left: 0,
            right: 0,
            height: _rowHeight,
            child: foreignRow,
          ),
          // DZD row: bottom when foreign→DZD, top when DZD→foreign.
          AnimatedPositioned(
            duration: duration,
            curve: Curves.easeInOutCubic,
            top: provider.isDZDtoCurrency ? topPos : bottomPos,
            left: 0,
            right: 0,
            height: _rowHeight,
            child: dzdRow,
          ),
          // Fixed pivot in the middle gap.
          Positioned(
            top: swapPos,
            right: 4,
            height: _swapSize,
            width: _swapSize,
            child: _SwapButton(
              onTap: provider.toggleConversionDirection,
              marketType: marketType,
            ),
          ),
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
