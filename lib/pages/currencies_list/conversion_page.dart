import 'package:flutter/material.dart';
import 'package:dinar_watch/theme/theme_manager.dart';
import 'package:dinar_watch/widgets/conversion_rate_info.dart';
import 'package:dinar_watch/widgets/flag_container.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:ui' as ui;
import 'package:dinar_watch/providers/currency_converter_provide.dart';
import 'package:provider/provider.dart';

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  CurrencyConverterPageState createState() => CurrencyConverterPageState();
}

class CurrencyConverterPageState extends State<CurrencyConverterPage>
    with SingleTickerProviderStateMixin {
  FocusNode amountFocusNode = FocusNode();
  FocusNode resultFocusNode = FocusNode();
  Widget flagPlaceholder = Container(
      width: 32, height: 32, color: const Color.fromARGB(255, 255, 0, 0));

  bool isDZDtoCurrency = false; // Conversion direction flag

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
  @override
  void dispose() {
    amountFocusNode.dispose();
    resultFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CurrencyConverterProvider>(context);
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
                      // Top Card - DZD input field
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        top: provider.isDZDtoCurrency
                            ? topCardTopPosition
                            : bottomCardTopPosition,
                        left: 16,
                        right: 16,
                        height: cardHeight,
                        child: _buildCurrencyInput(
                          'DZD',
                          null,
                          provider,
                          provider.isDZDtoCurrency,
                        ),
                      ),
                      // Bottom Card - Foreign currency input field
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        top: provider.isDZDtoCurrency
                            ? bottomCardTopPosition
                            : topCardTopPosition,
                        left: 16,
                        right: 16,
                        height: cardHeight,
                        child: _buildCurrencyInput(
                          provider.currency.currencyCode,
                          provider.currency.flag,
                          provider,
                          !provider.isDZDtoCurrency,
                        ),
                      ),
                      // FAB positioned in the middle of the cards, aligned to the right
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
                  conversionRateText: provider.getConversionRateText(),
                  textStyle: ThemeManager.moneyNumberStyle(context),
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyInput(String currencyCode, String? flag,
      CurrencyConverterProvider provider, bool isAmountField) {
    TextEditingController controller =
        isAmountField ? provider.amountController : provider.resultController;
    FocusNode focusNode =
        isAmountField ? provider.amountFocusNode : provider.resultFocusNode;

    bool isInputEnabled =
        isAmountField ? provider.isDZDtoCurrency : !provider.isDZDtoCurrency;

    var cardTheme = ThemeManager.currencyInputCardTheme(context);

    var themeBrightness = Theme.of(context).brightness;
    Color borderColor =
        themeBrightness == Brightness.dark ? Colors.white : Colors.black;
    borderColor = focusNode.hasFocus
        ? borderColor
        : borderColor.withOpacity(0.3); // Adjust opacity for unfocused state

    return Card(
      elevation: cardTheme.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: (cardTheme.shape as RoundedRectangleBorder).borderRadius,
        side: BorderSide(
          color: borderColor,
          width: focusNode.hasFocus ? 2.0 : 1.0,
        ),
      ),
      margin: cardTheme.margin,
      color: cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (currencyCode == 'DZD')
              Image.asset('assets/dz.png', width: 50, height: 40)
            else if (flag!.isNotEmpty)
              FlagContainer(
                imageUrl: flag,
                width: 50,
                height: 40,
                borderRadius: BorderRadius.circular(1),
              ),
            const SizedBox(width: 8.0),
            Expanded(
              child: TextField(
                focusNode: focusNode,
                controller: controller,
                decoration:
                    ThemeManager.currencyInputDecoration(context, currencyCode),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 0.0),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                enabled: isInputEnabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
