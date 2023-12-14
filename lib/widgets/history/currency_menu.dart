import 'package:flutter/material.dart';
import 'package:dinar_watch/models/currency.dart';

// Import other necessary packages and models
class CurrencyMenu {
  final List<Currency> coreCurrencies;
  final Function(String) onCurrencySelected;
  final BuildContext context;

  CurrencyMenu({
    required this.coreCurrencies,
    required this.onCurrencySelected,
    required this.context,
  });

  void showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: coreCurrencies.length,
          itemBuilder: (BuildContext context, int index) {
            final currency = coreCurrencies[index];
            return ListTile(
              title: Text(currency.currencyCode),
              onTap: () {
                onCurrencySelected(currency.currencyCode);
                Navigator.pop(context); // Close the modal bottom sheet
              },
            );
          },
        );
      },
    );
  }
}
