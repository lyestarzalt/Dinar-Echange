import 'package:flutter/material.dart';
import 'package:dinar_echange/data/models/currency.dart';
import 'package:dinar_echange/views/currencies_list/list_currencies_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  // Sample data for demonstration
  final List<Currency> alternativeMarketCurrencies = [
    /* your black market currencies */
  ];
  final List<Currency> officialMarketCurrencies = [
    /* your official market currencies */
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Markets'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Black Market'),
            Tab(text: 'Official Market'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CurrencyListScreen(currencies: alternativeMarketCurrencies),
          CurrencyListScreen(currencies: officialMarketCurrencies),
        ],
      ),
    );
  }
}
