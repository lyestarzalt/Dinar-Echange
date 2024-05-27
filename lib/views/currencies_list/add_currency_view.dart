import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'dart:ui' as ui;
import 'package:dinar_echange/data/models/currency.dart';
import 'package:dinar_echange/widgets/flag_container.dart';
import 'package:dinar_echange/providers/list_currency_provider.dart';

class AddCurrencyPage extends StatelessWidget {
  const AddCurrencyPage({super.key});
  @override
  @override
  Widget build(BuildContext context) {
    return Consumer<ListCurrencyProvider>(
      builder: (context, provider, child) {
        return Directionality(
          textDirection: ui.TextDirection.ltr,
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 90,
              title: TextField(
                controller: provider.searchController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.search_hint,
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
                    tooltip: AppLocalizations.of(context)!
                        .add_selected_currencies_tooltip,
                    child: const Icon(Icons.check),
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      separatorBuilder: (context, index) => const Divider(),
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
                              Expanded(
                                  child: Text(currency.currencyName ?? '')),
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
                          onTap: () => provider.addOrRemoveCurrency(
                              currency, !isSelected),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
