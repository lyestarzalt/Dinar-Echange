import 'package:flutter/material.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:google_fonts/google_fonts.dart';

class CurrencyMenu extends StatelessWidget {
  final List<Currency> coreCurrencies;
  final Function(String) onCurrencySelected;
  final BuildContext parentContext;

  CurrencyMenu({
    Key? key,
    required this.coreCurrencies,
    required this.onCurrencySelected,
    required this.parentContext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: coreCurrencies.length,
      itemBuilder: (BuildContext context, int index) {
        final currency = coreCurrencies[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            onTap: () {
              onCurrencySelected(currency.currencyCode);
              Navigator.pop(context); // Close the modal bottom sheet
            },
            leading: Container(
              width: 40,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                image: currency.flag != null
                    ? DecorationImage(
                        image: NetworkImage(currency.flag!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            title: Row(
              children: [
                Text(
                  currency.currencyName ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing: Text(
              currency.currencySymbol ?? '',
              style: GoogleFonts.notoSans(
                  fontSize: 18), // Use GoogleFonts to set the font family
            ),
          ),
        );
      },
    );
  }

  void showMenu() {
    showModalBottomSheet(
      context: parentContext,
      builder: (BuildContext context) => this,
    );
  }
}
