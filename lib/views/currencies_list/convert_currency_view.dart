import 'package:flutter/material.dart';
import 'package:dinar_watch/widgets/convert/currency_input.dart';
import 'package:dinar_watch/widgets/convert/number_words.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:ui' as ui;
import 'package:dinar_watch/providers/converter_provider.dart';
import 'package:provider/provider.dart';

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  CurrencyConverterPageState createState() => CurrencyConverterPageState();
}

class CurrencyConverterPageState extends State<CurrencyConverterPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ConvertProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final middlePoint = screenHeight * 0.2;
    const cardHeight = 100.0;
    const cardsgap = 5;
    final topCardTopPosition = middlePoint - cardHeight;
    final bottomCardTopPosition = middlePoint + cardsgap;
    const fabSize = 56.0;
    final fabTopPosition = middlePoint - (fabSize / 2);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.convert_app_bar_title),
        actions: [
          IconButton(
              tooltip:
                  AppLocalizations.of(context)!.currency_buy_sell_explanation,
              onPressed: () => showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(AppLocalizations.of(context)!
                              .currency_buy_sell_explanation),
                        ),
                      );
                    },
                  ),
              icon: const Icon(Icons.info_outline))
        ],
      ),
      body: Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 10,
                ),
/*                 ConversionRateInfo(
                  isDZDtoCurrency: provider.isDZDtoCurrency,
                  currency: provider.currency,
                ), */
                SizedBox(
                  height: screenHeight * 0.4,
                  child: Stack(
                    children: [
                      // Top Card - Foreign currency input field
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        top: provider.isDZDtoCurrency
                            ? topCardTopPosition
                            : bottomCardTopPosition,
                        left: 16,
                        right: 16,
                        height: cardHeight,
                        child: buildCurrencyInput(
                            controller: provider.isDZDtoCurrency
                                ? provider.amountController
                                : provider.resultController,
                            inputController: provider.amountController,
                            currencyCode: 'DZD',
                            flag: provider.currency.flag,
                            focusNode: provider.isDZDtoCurrency
                                ? provider.amountFocusNode
                                : provider.resultFocusNode,
                            context: context),
                      ),
                      // Bottom Card - Algerian currency field
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        top: provider.isDZDtoCurrency
                            ? bottomCardTopPosition
                            : topCardTopPosition,
                        left: 16,
                        right: 16,
                        height: cardHeight,
                        child: buildCurrencyInput(
                            controller: provider.isDZDtoCurrency
                                ? provider.resultController
                                : provider.amountController,
                            inputController: provider.amountController,
                            currencyCode: provider.currency.currencyCode,
                            flag: provider.currency.flag,
                            focusNode: provider.isDZDtoCurrency
                                ? provider.resultFocusNode
                                : provider.amountFocusNode,
                            context: context),
                      ),
                      // FAB positioned in the middle of the cards
                      Positioned(
                        top: fabTopPosition,
                        right: 8,
                        child: FloatingActionButton(
                          tooltip: AppLocalizations.of(context)!.switch_tooltip,
                          onPressed: provider.toggleConversionDirection,
                          elevation: 2,
                          child: const Icon(Icons.swap_vert),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Flexible(
                  child: Visibility(
                    visible: !provider.isDZDtoCurrency,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: NumberToWordsDisplay(
                        currency: provider.currency,
                        isDZDtoCurrency: !provider.isDZDtoCurrency,
                        numberController: provider.isDZDtoCurrency
                            ? provider.amountController
                            : provider.resultController,
                        provider: provider,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
