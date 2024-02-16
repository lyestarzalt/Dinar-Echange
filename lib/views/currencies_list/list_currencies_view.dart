import 'package:dinar_watch/utils/logging.dart';
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
import 'package:dinar_watch/utils/analytics_service.dart';
import 'package:dinar_watch/providers/admob_provider.dart';

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
          //selectionProvider!.filteredCurrencies[0].date CAN BE EMPTY
          String formattedDate = languageProvider
              .getDatetime(selectionProvider.filteredCurrencies[0].date);

          return Scaffold(
              appBar: AppBar(
                title: Text(
                  AppLocalizations.of(context)!.currencies_app_bar_title,
                ),
                actions: [
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 16.0, left: 16, top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          formattedDate,
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.update),
                      ],
                    ),
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
                          AnalyticsService.trackScreenView(
                              screenName: 'Converter');

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
                onPressed: () {
                  final adProvider =
                      Provider.of<AdProvider>(context, listen: false);
                  // Navigate first
                  AnalyticsService.trackScreenView(screenName: 'AddCurrencies');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider.value(
                        value: selectionProvider,
                        child: const AddCurrencyPage(),
                      ),
                    ),
                  ).then((_) {
                    // After navigating, check and possibly show the ad
                    if (adProvider.isInterstitialAdLoaded) {
                      adProvider.showInterstitialAd(
                        onAdClosed: () {
                          // Ad closed callback
                        },
                      );
                    } else {
                      adProvider.loadInterstitialAd();
                    }
                  });
                },
                tooltip: AppLocalizations.of(context)!.add_currencies_tooltip,
                child: const Icon(Icons.add),
              ));
        },
      ),
    );
  }
}
