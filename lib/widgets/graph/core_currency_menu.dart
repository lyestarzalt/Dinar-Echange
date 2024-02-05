import 'package:flutter/material.dart';
import 'package:dinar_watch/data/models/currency.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dinar_watch/widgets/flag_container.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CurrencyMenu extends StatefulWidget {
  final List<Currency> coreCurrencies;
  final Function(Currency) onCurrencySelected; // Change to accept Currency
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
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
          title:
              Text(AppLocalizations.of(context)!.select_currency_app_bar_title),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListView.separated(
            itemCount: widget.coreCurrencies.length,
            separatorBuilder: (context, index) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Divider(),
            ),
            itemBuilder: (BuildContext context, int index) {
              final currency = widget.coreCurrencies[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  onTap: () {
                    widget.onCurrencySelected(currency);

                    Navigator.pop(context);
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
        ),
      ),
    );
  }
}
