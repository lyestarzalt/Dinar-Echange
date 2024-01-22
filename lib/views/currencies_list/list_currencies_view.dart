import 'package:flutter/material.dart';
import 'package:dinar_watch/data/models/currency.dart';
import 'package:dinar_watch/providers/list_currency_provider.dart';
import 'package:dinar_watch/widgets/list/list_tile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:dinar_watch/views/currencies_list/add_currency_view.dart';
import 'package:dinar_watch/views/currencies_list/convert_currency_view.dart';
import 'package:dinar_watch/providers/converter_provider.dart';
import 'package:dinar_watch/providers/language_provider.dart';

class CurrencyListScreen extends StatelessWidget {
  final List<Currency> currencies;

  const CurrencyListScreen({super.key, required this.currencies});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ListCurrencyProvider>(
      create: (_) => ListCurrencyProvider(currencies),
      child: Consumer<ListCurrencyProvider>(
        builder: (context, selectionProvider, _) {
          LanguageProvider languageProvider =
              Provider.of<LanguageProvider>(context);

          String formattedDate = languageProvider
              .getDatetime(selectionProvider.filteredCurrencies[0].date);

          return Scaffold(
            appBar: AppBar(
              title: Text(
                AppLocalizations.of(context)!.currencies_app_bar_title,
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0, left: 16, top: 5),
                  child: Text(formattedDate),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider(
                              create: (_) => ConvertProvider(currency),
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
              tooltip: AppLocalizations.of(context)!.add_currencies_tooltip,
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
