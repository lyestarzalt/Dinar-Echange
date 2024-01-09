import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:ui' as ui;
import 'package:dinar_watch/data/models/currency.dart';
import 'package:dinar_watch/widgets/flag_container.dart';
import 'package:dinar_watch/providers/add_currency_provider.dart';

class AddCurrencyPage extends StatelessWidget {
  const AddCurrencyPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencySelectionProvider>(
      builder: (context, provider, child) {
        final TextEditingController searchController = TextEditingController();
        searchController.addListener(() {
          provider.filterCurrencies(searchController.text);
        });

        return Directionality(
          textDirection: ui.TextDirection.ltr,
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 100,
              title: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.search,
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: () {
                      provider.saveSelectedCurrencies();
                      Navigator.pop(context);
                    },
                    tooltip:
                        AppLocalizations.of(context)!.add_selected_currencies,
                    child: const Icon(Icons.check),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.filteredCurrencies.length,
                    itemBuilder: (context, index) {
                      final Currency currency =
                          provider.filteredCurrencies[index];
                      final bool isSelected =
                          provider.selectedCurrencies.contains(currency);
                      return ListTile(
                        leading: FlagContainer(
                          imageUrl: currency.flag,
                          width: 50,
                          height: 40,
                          borderRadius: BorderRadius.circular(1),
                        ),
                        title: Row(
                          children: [
                            Text(currency.currencyCode),
                            const SizedBox(width: 10),
                            Expanded(child: Text(currency.currencyName ?? '')),
                          ],
                        ),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            if (value != null) {
                              provider.addOrRemoveCurrency(currency, value);
                            }
                          },
                        ),
                        onTap: () =>
                            provider.addOrRemoveCurrency(currency, !isSelected),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
