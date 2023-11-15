import 'package:flutter/material.dart';
import '../models/currency.dart'; // Replace with your actual import path

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
        isDZDtoCurrency ? widget.currency.sell : 1 / widget.currency.buy;
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
        isDZDtoCurrency ? widget.currency.sell : 1 / widget.currency.buy;
    double convertedAmount = amount * conversionRate;

    resultController.text = convertedAmount.toStringAsFixed(2);
  }

  void _swapCurrencies() {
    setState(() {
      isDZDtoCurrency = !isDZDtoCurrency;
      // Swap the contents of the controllers as well
      String temp = amountController.text;
      amountController.text = resultController.text;
      resultController.text = temp;
    });
    _convertCurrency();
  }

  @override
  Widget build(BuildContext context) {
    // Adjust the starting top position based on your preference
    final double fieldStartingTopPosition =
        MediaQuery.of(context).size.height * 0.1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Convert'),
      ),
      body: Stack(
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
          // Switch button
          Positioned(
            top: fieldStartingTopPosition * 1.5,
            right: 8,
            child: FloatingActionButton(
              onPressed: _swapCurrencies,
              elevation: 2,
              backgroundColor: Colors.white,
              child: const Icon(Icons.swap_vert), // Change as needed
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyInput(
      TextEditingController controller, String currencyCode, Widget flag) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            flag,
            const SizedBox(width: 8.0),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: currencyCode,
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 24.0),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
