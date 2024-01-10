import 'package:flutter/material.dart';
import 'package:dinar_watch/data/models/currency.dart';
import 'package:dinar_watch/providers/list_currency_provider.dart';
import 'package:dinar_watch/widgets/list/list_tile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:dinar_watch/views/currencies_list/add_currency_view.dart';
import 'package:dinar_watch/views/currencies_list/convert_currency_view.dart';
import 'package:dinar_watch/providers/converter_provider.dart';

class CurrencyListScreen extends StatelessWidget {
  final List<Currency> currencies;

  const CurrencyListScreen({super.key, required this.currencies});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ListCurrencyProvider>(
      create: (_) => ListCurrencyProvider(currencies),
      child: Consumer<ListCurrencyProvider>(
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
                                  ConvertProvider(currency),
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
