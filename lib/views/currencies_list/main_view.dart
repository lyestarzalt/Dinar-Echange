import 'package:flutter/material.dart';
import 'package:dinar_echange/data/models/currency.dart';
import 'package:dinar_echange/views/currencies_list/list_currencies_view.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:dinar_echange/providers/app_provider.dart';
import 'package:provider/provider.dart';
import 'package:dinar_echange/providers/list_currency_provider.dart';

class MainView extends StatefulWidget {
  final List<Currency> alternativeMarketCurrencies;
  final List<Currency> officialMarketCurrencies;

  const MainView({
    super.key,
    required this.alternativeMarketCurrencies,
    required this.officialMarketCurrencies,
  });

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    print('hello from main view here is the data during initstate ${widget.alternativeMarketCurrencies}');
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    String formattedDate =
        appProvider.getDatetime(widget.alternativeMarketCurrencies.first.date);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.currencies_app_bar_title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 16, top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(formattedDate),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.parallel_market),
            Tab(text: AppLocalizations.of(context)!.official_market),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ChangeNotifierProvider(
            create: (_) => ListCurrencyProvider(
              currencies: widget.alternativeMarketCurrencies,
              marketType: 'alternative',
            ),
            child: CurrencyListScreen(
              marketType: 'alternative',
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => ListCurrencyProvider(
              currencies: widget.officialMarketCurrencies,
              marketType: 'official',
            ),
            child: CurrencyListScreen(
              marketType: 'official',
            ),
          ),
        ],
      ),
    );
  }
}
