import 'package:flutter/material.dart';
import 'package:dinar_watch/widgets/convert/conversion_rate_info.dart';
import 'package:dinar_watch/widgets/convert/currency_input.dart';
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
        title: Text(AppLocalizations.of(context)!.convert),
      ),
      body: Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                            provider.isDZDtoCurrency
                                ? provider.amountController
                                : provider.resultController,
                            provider.amountController,
                            'DZD',
                            provider.currency.flag,
                            provider.isDZDtoCurrency
                                ? provider.amountFocusNode
                                : provider.resultFocusNode,
                            context),
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
                            provider.isDZDtoCurrency
                                ? provider.resultController
                                : provider.amountController,
                            provider.amountController,
                            provider.currency.currencyCode,
                            provider.currency.flag,
                            provider.isDZDtoCurrency
                                ? provider.resultFocusNode
                                : provider.amountFocusNode,
                            context),
                      ),
                      // FAB positioned in the middle of the cards
                      Positioned(
                        top: fabTopPosition,
                        right: 8,
                        child: FloatingActionButton(
                          onPressed: provider.toggleConversionDirection,
                          elevation: 2,
                          child: const Icon(Icons.swap_vert),
                        ),
                      ),
                    ],
                  ),
                ),
                ConversionRateInfo(
                  isDZDtoCurrency: provider.isDZDtoCurrency,
                  currency: provider.currency,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
