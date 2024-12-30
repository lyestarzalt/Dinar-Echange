import 'package:flutter/material.dart';
import 'package:dinar_echange/data/models/currency_model.dart';
import 'package:dinar_echange/providers/list_currency_provider.dart';
import 'package:dinar_echange/widgets/list/list_tile.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:dinar_echange/views/currencies_list/add_currency_view.dart';
import 'package:dinar_echange/views/currencies_list/convert_currency_view.dart';
import 'package:dinar_echange/providers/converter_provider.dart';
import 'package:dinar_echange/providers/app_provider.dart';
import 'package:dinar_echange/providers/admob_provider.dart';
import 'dart:math';
import 'package:dinar_echange/services/remote_config_service.dart';

class CurrencyListScreen extends StatefulWidget {
  final String marketType;

  const CurrencyListScreen({super.key, required this.marketType});

  @override
  _CurrencyListScreenState createState() => _CurrencyListScreenState();
}

class _CurrencyListScreenState extends State<CurrencyListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: Consumer<ListCurrencyProvider>(
            builder: (_, provider, __) => ReorderableListView.builder(
              shrinkWrap: true,
              itemCount: provider.selectedCurrencies.length,
              itemBuilder: (context, index) =>
                  _buildCurrencyItem(context, provider, index),
              onReorder: provider.reorderCurrencies,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCurrencyPage(context),
        tooltip: AppLocalizations.of(context)!.add_currencies_tooltip,
        heroTag: 'AddCurrencyFAB${widget.marketType}',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    final provider = Provider.of<ListCurrencyProvider>(context, listen: false);
    final appprovider = Provider.of<AppProvider>(context, listen: false);

    await provider.refreshData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${AppLocalizations.of(context)!.latest_updates_on} ${appprovider.getDatetime(provider.getFormattedDate())}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildCurrencyItem(
      BuildContext context, ListCurrencyProvider provider, int index) {
    final currency = provider.selectedCurrencies[index];
    return Dismissible(
      key: ValueKey(currency.currencyCode),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (DismissDirection direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title:
                      Text(AppLocalizations.of(context)!.confirm_delete_title),
                  content: Text(
                      AppLocalizations.of(context)!.confirm_delete_message),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        provider.addOrRemoveCurrency(currency, false);
                        Navigator.of(context).pop(true);
                      },
                      child: Text(AppLocalizations.of(context)!.delete),
                    ),
                  ],
                );
              },
            ) ??
            false; // Return false if null is returned (dialog is dismissed)
      },
      onDismissed: (direction) {
        //TODO
        /*     provider.addOrRemoveCurrency(currency, false);    
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Currency ${currency.currencyCode} deleted'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                provider.addCurrency(
                    currency); // Possibly re-add the item if user undoes
              },
            ),
          ),
        ); */
      },
      child: InkWell(
        onTap: () => _navigateToConverter(context, currency),
        child: CurrencyListItem(currency: currency),
      ),
    );
  }

  void _navigateToConverter(BuildContext context, Currency currency) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ConvertProvider(currency),
          child: CurrencyConverterPage(marketType: widget.marketType),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

Future<void> _showAddCurrencyPage(BuildContext context) async {
  final AdProvider adProvider = Provider.of<AdProvider>(context, listen: false);

  if (await shouldShowAd('ad_show_chance_open')) {
    // 30% chance to show the ad
    if (adProvider.isInterstitialAdLoaded) {
      adProvider.showInterstitialAd();
      adProvider.onAdDismissed(() {
        _navigateToAddCurrencyPage(context);
      });
    } else {
      _navigateToAddCurrencyPage(context);
    }
  } else {
  
    _navigateToAddCurrencyPage(context);
  }
}

void _navigateToAddCurrencyPage(BuildContext context) {
  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: Provider.of<ListCurrencyProvider>(context, listen: false),
          child: const AddCurrencyPage(),
        ),
      ));
}

Future<bool> shouldShowAd(String type) async {
  int chanceToShowAd =
      await RemoteConfigService.instance.fetchAdShowChance(type);
  return Random().nextInt(100) < chanceToShowAd;
}
