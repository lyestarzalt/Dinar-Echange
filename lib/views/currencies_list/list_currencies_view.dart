import 'package:flutter/material.dart';
import 'package:dinar_echange/data/models/currency.dart';
import 'package:dinar_echange/providers/list_currency_provider.dart';
import 'package:dinar_echange/widgets/list/list_tile.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:dinar_echange/views/currencies_list/add_currency_view.dart';
import 'package:dinar_echange/views/currencies_list/convert_currency_view.dart';
import 'package:dinar_echange/providers/converter_provider.dart';
import 'package:dinar_echange/providers/app_provider.dart';
import 'package:dinar_echange/providers/admob_provider.dart';
import 'package:dinar_echange/utils/logging.dart';

class CurrencyListScreen extends StatefulWidget {
  final String marketType;

  const CurrencyListScreen({Key? key, required this.marketType})
      : super(key: key);

  @override
  _CurrencyListScreenState createState() => _CurrencyListScreenState();
}

class _CurrencyListScreenState extends State<CurrencyListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final selectionProvider = Provider.of<ListCurrencyProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);

    String formattedDate =
        appProvider.getDatetime(selectionProvider.allCurrencies[0].date);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: RefreshIndicator(
          onRefresh: () async {
            await selectionProvider.refreshData().then((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${AppLocalizations.of(context)!.latest_updates_on} $formattedDate'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            });
          },
          child: ReorderableListView.builder(
            shrinkWrap: true,
            itemCount: selectionProvider.selectedCurrencies.length,
            itemBuilder: (context, index) {
              final Currency currency =
                  selectionProvider.selectedCurrencies[index];
              return Dismissible(
                key: ValueKey(currency.currencyCode),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  selectionProvider.addOrRemoveCurrency(currency, false);
                },
                child: InkWell(
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
                  child: CurrencyListItem(currency: currency),
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
        onPressed: () => showAddCurrencyPage(context, selectionProvider),
        tooltip: AppLocalizations.of(context)!.add_currencies_tooltip,
        child: const Icon(Icons.add),
        heroTag: 'AddCurrencyFAB${widget.marketType}',
      ),
    );
  }

  bool get wantKeepAlive => true; // Important to keep state alive
}

void showAddCurrencyPage(
    BuildContext context, ListCurrencyProvider selectionProvider) {
  AppLogger.trackScreenView('AddCurrencies_Screen', 'MainList');
  final adProvider = Provider.of<AdProvider>(context, listen: false);

  adProvider.ensureAdIsReadyToShow(
    onReadyToShow: () => _navigateToAddCurrencyPage(context, selectionProvider),
    onFailToShow: () => _navigateToAddCurrencyPage(context, selectionProvider),
  );
}

void _navigateToAddCurrencyPage(
    BuildContext context, ListCurrencyProvider selectionProvider) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChangeNotifierProvider.value(
        value: selectionProvider,
        child: const AddCurrencyPage(),
      ),
    ),
  );
}
