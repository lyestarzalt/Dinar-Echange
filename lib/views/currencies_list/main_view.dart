import 'package:flutter/material.dart';
import 'package:dinar_echange/data/models/currency.dart';
import 'package:dinar_echange/views/currencies_list/list_currencies_view.dart';
import 'package:provider/provider.dart';
import 'package:dinar_echange/providers/list_currency_provider.dart';

class MainView extends StatefulWidget {
  final List<Currency> alternativeMarketCurrencies;
  final List<Currency> officialMarketCurrencies;

  const MainView({
    Key? key,
    required this.alternativeMarketCurrencies,
    required this.officialMarketCurrencies,
  }) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currencies'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Alternative Market'),
            Tab(text: 'Official Market'),
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
            child: CurrencyListScreen(marketType: 'alternative'),
          ),
          ChangeNotifierProvider(
            create: (_) => ListCurrencyProvider(
              currencies: widget.officialMarketCurrencies,
              marketType: 'official',
            ),
            child: CurrencyListScreen(marketType: 'official'),
          ),
        ],
      ),
    );
  }
}
