import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dinar_echange/data/models/currency_model.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:dinar_echange/providers/app_provider.dart';
import 'package:dinar_echange/providers/appinit_provider.dart';
import 'package:dinar_echange/providers/list_currency_provider.dart';
import 'package:dinar_echange/utils/logging.dart';
import 'package:dinar_echange/views/currencies_list/list_currencies_view.dart';
import 'package:dinar_echange/widgets/flag_container.dart';
import 'package:dinar_echange/widgets/list/hero_currency_card.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _flagsPrecached = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _tabController!.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController!.indexIsChanging) {
      switch (_tabController!.index) {
        case 0:
          AppLogger.trackScreenView('Parallel Market', 'MainList');
          break;
        case 1:
          AppLogger.trackScreenView('Official Market', 'MainList');
          break;
      }
    }
  }

  @override
  void dispose() {
    _tabController!.removeListener(_handleTabSelection);
    _tabController!.dispose();
    super.dispose();
  }

  /// Preload the flag PNGs for every currency in either market so the
  /// first render of the list doesn't decode them all in the same
  /// raster frame — that decode spike was the visible jank when the
  /// tab body first paints.
  void _maybePrecacheFlags(BuildContext context, List<Currency> currencies) {
    if (_flagsPrecached) return;
    _flagsPrecached = true;
    for (final c in currencies) {
      final asset = flagAssetPathFor(c.flag);
      if (asset != null) {
        precacheImage(AssetImage(asset), context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    // Selector rebuilds this subtree only when either currency list's
    // *identity* changes — theme swaps, locale changes, focus events on
    // any other AppInit field no longer trigger a rebuild of the whole
    // screen. Consumer previously rebuilt on every notify.
    return Selector<AppInitializationProvider,
        (List<Currency>, List<Currency>)>(
      selector: (_, p) => (
        p.currencies ?? const <Currency>[],
        p.officialCurrencies ?? const <Currency>[],
      ),
      builder: (context, lists, _) {
        final alternativeMarketCurrencies = lists.$1;
        final officialMarketCurrencies = lists.$2;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _maybePrecacheFlags(context, alternativeMarketCurrencies);
          _maybePrecacheFlags(context, officialMarketCurrencies);
        });

        // Featured currency: prefer EUR (the reference rate most Algerians
        // check), otherwise the first parallel-market entry.
        Currency? featured;
        for (final c in alternativeMarketCurrencies) {
          if (c.currencyCode == 'EUR') {
            featured = c;
            break;
          }
        }
        featured ??= alternativeMarketCurrencies.isNotEmpty
            ? alternativeMarketCurrencies.first
            : null;

        return Scaffold(
          appBar: AppBar(
            title:
                Text(AppLocalizations.of(context)!.currencies_app_bar_title),
            actions: [
              if (alternativeMarketCurrencies.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.only(right: 16.0, left: 16, top: 5),
                  child: Text(appProvider
                      .getDatetime(alternativeMarketCurrencies.first.date)),
                ),
            ],
          ),
          body: Column(
            children: [
              if (featured != null) HeroCurrencyCard(currency: featured),
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.parallel_market),
                  Tab(text: AppLocalizations.of(context)!.official_market),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ChangeNotifierProvider(
                      create: (_) => ListCurrencyProvider(
                        currencies: alternativeMarketCurrencies,
                        marketType: 'alternative',
                      ),
                      child:
                          const CurrencyListScreen(marketType: 'alternative'),
                    ),
                    ChangeNotifierProvider(
                      create: (_) => ListCurrencyProvider(
                        currencies: officialMarketCurrencies,
                        marketType: 'official',
                      ),
                      child: const CurrencyListScreen(marketType: 'official'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
