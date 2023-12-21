import 'package:flutter/material.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dinar_watch/widgets/flag_container.dart';

class CurrencyMenu extends StatefulWidget {
  final List<Currency> coreCurrencies;
  final Function(String) onCurrencySelected;
  final BuildContext parentContext;

  const CurrencyMenu({
    super.key,
    required this.coreCurrencies,
    required this.onCurrencySelected,
    required this.parentContext,
  });

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
        title:const Text('Select Currency'), // Or any other title you prefer
      ),
      body: ListView.separated(
        itemCount: widget.coreCurrencies.length,
        separatorBuilder: (context, index) =>
            const Divider(), // divider between list items
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
            leading: FlagContainer(
                imageUrl: currency.flag,
                width: 50,
                height: 40,
                borderRadius: BorderRadius.circular(1),
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
