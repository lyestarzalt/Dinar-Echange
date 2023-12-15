import 'package:flutter/material.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';

class CurrencyMenu extends StatefulWidget {
  final List<Currency> coreCurrencies;
  final Function(String) onCurrencySelected;
  final BuildContext parentContext;

  const CurrencyMenu({
    Key? key,
    required this.coreCurrencies,
    required this.onCurrencySelected,
    required this.parentContext,
  }) : super(key: key);

  @override
  State<CurrencyMenu> createState() => _CurrencyMenuState();
}

class _CurrencyMenuState extends State<CurrencyMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Select Currency'), // Or any other title you prefer
      ),
      body: ListView.separated(
        itemCount: widget.coreCurrencies.length,
        separatorBuilder: (context, index) =>
            Divider(), // Adds a divider between list items
        itemBuilder: (BuildContext context, int index) {
          final currency = widget.coreCurrencies[index];
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              onTap: () {
                widget.onCurrencySelected(currency.currencyCode);
                Navigator.pop(context); // Close the modal
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
              title: Text(
                currency.currencyName ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Text(
                currency.currencySymbol ?? '',
                style: GoogleFonts.notoSans(fontSize: 18),
              ),
            ),
          );
        },
      ),
    );
  }
}
