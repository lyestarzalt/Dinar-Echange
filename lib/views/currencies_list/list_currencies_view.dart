import 'package:flutter/material.dart';
import 'package:dinar_watch/data/models/currency.dart';
import 'package:dinar_watch/providers/add_currency_provider.dart';
import 'package:dinar_watch/widgets/list/currency_list_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:dinar_watch/views/currencies_list/add_currency_view.dart';
import 'package:dinar_watch/views/currencies_list/convert_currency_view.dart';
import 'package:dinar_watch/providers/converter_provider.dart';

class CurrencyListScreen extends StatelessWidget {
  const CurrencyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CurrencySelectionProvider>(
      create: (_) => CurrencySelectionProvider(),
      child: Consumer<CurrencySelectionProvider>(
        builder: (context, selectionProvider, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.currency_list),
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(1, 0, 1, 0),
              child: RefreshIndicator(
                onRefresh: () async {
                  // TODO Implement the refresh logic
                },
                child: ReorderableListView.builder(
                  itemCount: selectionProvider.selectedCurrencies.length,
                  itemBuilder: (context, index) {
                    final Currency currency =
                        selectionProvider.selectedCurrencies[index];
                    return InkWell(
                      key: ValueKey(currency.currencyCode),
                      onTap: () {
                        // Navigate to CurrencyConverterPage with the selected currency
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider(
                              create: (_) =>
                                  CurrencyConverterProvider(currency),
                              child: const CurrencyConverterPage(),
                            ),
                          ),
                        );
                      },
                      child: CurrencyListItem(
                        key: ValueKey(currency.currencyCode),
                        currency: currency,
                      ),
                    );
                  },
                  onReorder: (int oldIndex, int newIndex) {
                    selectionProvider.reorderCurrencies(oldIndex, newIndex);
                  },
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider.value(
                    value: selectionProvider,
                    child: const AddCurrencyPage(),
                  ),
                ),
              ),
              tooltip: AppLocalizations.of(context)!.add_currencies,
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
