import 'package:flutter/material.dart';
import '../models/currency.dart'; // Replace with your actual import path
import 'package:dinar_watch/theme_manager.dart';

class CurrencyConverterPage extends StatefulWidget {
  final Currency currency; // The currency selected from the list

  const CurrencyConverterPage({Key? key, required this.currency})
      : super(key: key);

  @override
  _CurrencyConverterPageState createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage>
    with SingleTickerProviderStateMixin {
  // Controllers for the two text fields
  TextEditingController amountController = TextEditingController();
  TextEditingController resultController = TextEditingController();

  // Placeholder for flags, replace with actual Image.asset or similar
  Widget flagPlaceholder = Container(width: 32, height: 32, color: Colors.grey);

  bool isDZDtoCurrency = true; // Conversion direction flag

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Whenever the amount changes, update the result.
    amountController.addListener(_convertCurrency);
  }

  @override
  void dispose() {
    _animationController.dispose();
    amountController.dispose();
    resultController.dispose();
    amountController.removeListener(_onAmountChanged);
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
    double conversionRate =
        isDZDtoCurrency ? 1 / widget.currency.sell : widget.currency.buy;
    double convertedAmount = amount * conversionRate;

    resultController.text = convertedAmount.toStringAsFixed(2);
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
      return '100 DZD = ${(100 / widget.currency.buy).toStringAsFixed(2)} ${widget.currency.name.toUpperCase()}';
    } else {
      // Displaying conversion from the selected currency to DZD
      return '1 ${widget.currency.name.toUpperCase()} = ${(widget.currency.sell * 1).toStringAsFixed(2)} DZD';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Adjust the starting top position based on your preference
    final double fieldStartingTopPosition =
        MediaQuery.of(context).size.height * 0.15; // Increased spacing

    // Calculate the top position for the switch button to place it in the middle
    final switchButtonTopPosition =
        (fieldStartingTopPosition + (fieldStartingTopPosition * 2)) / 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Convert'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height *
                  0.5, // Adjust the height as needed
              child: Stack(
                children: [
                  // DZD input field
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    top: isDZDtoCurrency
                        ? fieldStartingTopPosition
                        : fieldStartingTopPosition * 2,
                    left: 16,
                    right: 16,
                    child: _buildCurrencyInput(
                      isDZDtoCurrency ? amountController : resultController,
                      'DZD',
                      flagPlaceholder,
                    ),
                  ),
                  // Foreign currency input field
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    top: isDZDtoCurrency
                        ? fieldStartingTopPosition * 2
                        : fieldStartingTopPosition,
                    left: 16,
                    right: 16,
                    child: _buildCurrencyInput(
                      isDZDtoCurrency ? resultController : amountController,
                      widget.currency.name,
                      flagPlaceholder,
                    ),
                  ),
                  // Switch button placed in the middle
                  Positioned(
                    top: switchButtonTopPosition * 1.1,
                    right: 8,
                    child: FloatingActionButton(
                      onPressed: _swapCurrencies,
                      child: const Icon(Icons.swap_vert),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
                height:
                    20), // Add space between the stack and the rate information
            Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20), // Increased padding for a bigger container
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceVariant, // Use a light grey color for the container
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getConversionRateText(), // Rounded to two decimal places
                style: ThemeManager.moneyNumberStyle(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyInput(
      TextEditingController controller, String currencyCode, Widget flag) {
    bool isInputEnabled =
        controller == amountController; // Enable input only for the top field
    var cardTheme = ThemeManager.currencyInputCardTheme(context);
    return Card(
      elevation: cardTheme.elevation,
      shape: cardTheme.shape,
      margin: cardTheme.margin,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            flag,
            const SizedBox(width: 8.0),
            Expanded(
              child: TextField(
                controller: controller,
                decoration:
                    ThemeManager.currencyInputDecoration(context, currencyCode),
                style: TextStyle(
                  fontSize: 24.0,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface, // Explicit text color
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.left,
                enabled: isInputEnabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
