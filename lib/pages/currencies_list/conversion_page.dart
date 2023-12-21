import 'package:flutter/material.dart';
import '../../models/currency.dart'; // Replace with your actual import path
import 'package:dinar_watch/theme_manager.dart';
import 'package:dinar_watch/utils/finance_utils.dart';
import 'package:decimal/decimal.dart';
import 'package:dinar_watch/widgets/conversion_rate_info.dart';
import 'package:dinar_watch/widgets/flag_container.dart';

class CurrencyConverterPage extends StatefulWidget {
  final Currency currency; // The currency selected from the list

  const CurrencyConverterPage({super.key, required this.currency});

  @override
  CurrencyConverterPageState createState() => CurrencyConverterPageState();
}

class CurrencyConverterPageState extends State<CurrencyConverterPage>
    with SingleTickerProviderStateMixin {
  // Controllers for the two text fields
  TextEditingController amountController = TextEditingController();
  TextEditingController resultController = TextEditingController();
  FocusNode amountFocusNode = FocusNode();
  FocusNode resultFocusNode = FocusNode();
  // Placeholder for flags, replace with actual Image.asset or similar
  Widget flagPlaceholder = Container(
      width: 32, height: 32, color: const Color.fromARGB(255, 255, 0, 0));

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
    amountController.addListener(_convertCurrency);
    amountFocusNode.addListener(_updateFocus);
    resultFocusNode.addListener(_updateFocus);
  }

  @override
  void dispose() {
    _animationController.dispose();
    amountController.dispose();
    resultController.dispose();
    amountController.removeListener(_onAmountChanged);
    amountFocusNode.dispose();
    resultFocusNode.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    if (amountController.text.isEmpty) {
      resultController.text = '';
      return;
    }

    double rate =
        isDZDtoCurrency ? 1 / widget.currency.sell : widget.currency.buy;
    double amount = double.tryParse(amountController.text) ?? 0.0;
    double result = amount * rate;

    resultController.text = result.toStringAsFixed(2);
  }

  void _convertCurrency() {
    if (amountController.text.isEmpty) {
      resultController.clear();
      return;
    }

    double amount = double.tryParse(amountController.text) ?? 0.0;
    String convertedAmount = FinanceUtils.convertAmount(
        amount,
        isDZDtoCurrency ? widget.currency.buy : widget.currency.sell,
        isDZDtoCurrency);

    resultController.text = convertedAmount;
  }

  void _swapCurrencies() {
    setState(() {
      isDZDtoCurrency = !isDZDtoCurrency;

      // Store the values of both fields
      String amountValue = amountController.text;
      String resultValue = resultController.text;

      // Swap the contents of the controllers
      amountController.text = resultValue;
      resultController.text = amountValue;
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

  @override
  Widget build(BuildContext context) {
    // Calculate the middle point of the screen
    final screenHeight = MediaQuery.of(context).size.height;
    final middlePoint = screenHeight * 0.2;

    // Calculate the height for each card
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
        title: const Text('Convert'),
      ),
      body: SingleChildScrollView(
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
                      isDZDtoCurrency ? amountController : resultController,
                      'DZD',
                      widget.currency.flag,
                      isDZDtoCurrency
                          ? amountFocusNode
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
                      isDZDtoCurrency ? resultController : amountController,
                      widget.currency.currencyCode,
                      widget.currency.flag,
                      isDZDtoCurrency
                          ? resultFocusNode
                          : amountFocusNode, // Pass the FocusNode
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
    );
  }

  Widget _buildCurrencyInput(TextEditingController controller,
      String currencyCode, String? flag, FocusNode focusNode) {
    bool isInputEnabled = controller == amountController;
    var cardTheme = ThemeManager.currencyInputCardTheme(context);

    // Determine border color based on theme brightness
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
          width: focusNode.hasFocus
              ? 2.0
              : 1.0, // Adjust border width based on focus
        ),
      ),
      margin: cardTheme.margin,
      color: cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            // Use a local asset for the Algerian flag, and a network image for others
            if (currencyCode ==
                'DZD') // Assuming 'DZD' is the currency code for Algeria
              Image.asset('assets/dz.png', width: 50, height: 40)
            else if (flag!.isNotEmpty)
             FlagContainer(
  imageUrl: flag,
  width: 50,
  height: 40,
  borderRadius: BorderRadius.circular(1),
),

            const SizedBox(
              width: 8.0,
            ),
            Expanded(
              child: TextField(
                focusNode: focusNode,
                controller: controller,
                decoration:
                    ThemeManager.currencyInputDecoration(context, currencyCode),
                style: ThemeManager.currencyCodeStyle(context),
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
