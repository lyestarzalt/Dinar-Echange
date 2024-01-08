import 'package:flutter/material.dart';
import '../../models/currency.dart'; // Replace with your actual import path
import 'package:dinar_watch/theme/theme_manager.dart';
import 'package:dinar_watch/utils/finance_utils.dart';
import 'package:decimal/decimal.dart';
import 'package:dinar_watch/widgets/conversion_rate_info.dart';
import 'package:dinar_watch/widgets/flag_container.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:ui' as ui;

class CurrencyConverterPage extends StatefulWidget {
  final Currency currency; // The currency selected from the list

  const CurrencyConverterPage({super.key, required this.currency});

  @override
  CurrencyConverterPageState createState() => CurrencyConverterPageState();
}

class CurrencyConverterPageState extends State<CurrencyConverterPage>
    with SingleTickerProviderStateMixin {
  TextEditingController inputController = TextEditingController();
  TextEditingController resultController = TextEditingController();
  FocusNode inputFocusNode = FocusNode();
  FocusNode resultFocusNode = FocusNode();

  bool isDZDtoCurrency = false; // Conversion direction flag

  late AnimationController _animationController;
  void _updateFocus() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Whenever the amount changes, update the result.
    inputController.addListener(_convertCurrency);
    inputFocusNode.addListener(_updateFocus);
    resultFocusNode.addListener(_updateFocus);
  }

  @override
  void dispose() {
    _animationController.dispose();
    inputController.dispose();
    resultController.dispose();
    inputController.removeListener(_onAmountChanged);
    inputFocusNode.dispose();
    resultFocusNode.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    if (inputController.text.isEmpty) {
      resultController.text = '';
      return;
    }

    double rate =
        isDZDtoCurrency ? 1 / widget.currency.sell : widget.currency.buy;
    double amount = double.tryParse(inputController.text) ?? 0.0;
    double result = amount * rate;

    resultController.text = result.toStringAsFixed(2);
  }

  void _convertCurrency() {
    if (inputController.text.isEmpty) {
      resultController.clear();
      return;
    }

    double amount = double.tryParse(inputController.text) ?? 0.0;
    String convertedAmount = FinanceUtils.convertAmount(
        amount,
        isDZDtoCurrency ? widget.currency.buy : widget.currency.sell,
        isDZDtoCurrency);

    resultController.text = convertedAmount;
  }

  void _swapCurrencies() {
    setState(() {
      isDZDtoCurrency = !isDZDtoCurrency;
      // Swap the contents of the controllers
      inputController.text = resultController.text;
      resultController.text = inputController.text;
    });
  }

  String _getConversionRateText() {
    if (isDZDtoCurrency) {
      // Displaying conversion from DZD to the selected currency
      Decimal conversionRate =
          Decimal.parse((100 / widget.currency.buy).toString());
      return '100 DZD = ${conversionRate.toStringAsFixed(2)} ${widget.currency.currencyCode.toUpperCase()}';
    } else {
      // Displaying conversion from the selected currency to DZD
      Decimal conversionRate =
          Decimal.parse((widget.currency.sell * 1).toString());
      return '1 ${widget.currency.currencyCode.toUpperCase()} = ${conversionRate.toStringAsFixed(2)} DZD';
    }
  }

  bool isActive() {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the middle point of the screen
    final screenHeight = MediaQuery.of(context).size.height;
    final middlePoint = screenHeight * 0.2;

    //  The height for each card
    const cardHeight = 100.0;

    // Calculate the top positions for the animated positioned cards
    const cardsgap = 5;
    final topCardTopPosition = middlePoint - cardHeight;
    final bottomCardTopPosition = middlePoint + cardsgap;

    // Calculate the FAB position
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
                        top: isDZDtoCurrency
                            ? topCardTopPosition
                            : bottomCardTopPosition,
                        left: 16,
                        right: 16,
                        height: cardHeight,
                        child: _buildCurrencyInput(
                          isDZDtoCurrency ? inputController : resultController,
                          inputController,
                          'DZD',
                          widget.currency.flag,
                          isDZDtoCurrency
                              ? inputFocusNode
                              : resultFocusNode, // Pass the FocusNode
                        ),
                      ),
                      // Bottom Card - Foreign currency input field
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        top: isDZDtoCurrency
                            ? bottomCardTopPosition
                            : topCardTopPosition,
                        left: 16,
                        right: 16,
                        height: cardHeight,
                        child: _buildCurrencyInput(
                          isDZDtoCurrency ? resultController : inputController,
                          inputController,
                          widget.currency.currencyCode,
                          widget.currency.flag,
                          isDZDtoCurrency
                              ? resultFocusNode
                              : inputFocusNode, // Pass the FocusNode
                        ),
                      ),
                      // FAB positioned in the middle of the cards, aligned to the right
                      Positioned(
                        top: fabTopPosition,
                        right: 8,
                        child: FloatingActionButton(
                          onPressed: _swapCurrencies,
                          elevation: 2,
                          child: const Icon(Icons.swap_vert),
                        ),
                      ),
                    ],
                  ),
                ),
                ConversionRateInfo(
                  conversionRateText: _getConversionRateText(),
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

  Widget _buildCurrencyInput(
      TextEditingController controller,
      TextEditingController inputControl,
      String currencyCode,
      String? flag,
      FocusNode focusNode) {
    bool isInputEnabled = controller == inputControl;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: BorderSide(
          color: focusNode.hasFocus
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context)
                  .colorScheme
                  .onPrimaryContainer
                  .withOpacity(0.3),
          width: focusNode.hasFocus ? 3.0 : 0.5,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      color: Theme.of(context).colorScheme.background,
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
