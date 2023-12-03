import 'package:flutter/material.dart';
import '../models/currency.dart';
import 'add_currency_page.dart';
import '../services/preferences_service.dart';
import 'package:dinar_watch/widgets/currency_list_item.dart';

class CurrencyListScreen extends StatefulWidget {
  final Future<List<Currency>> currenciesFuture;

  const CurrencyListScreen({Key? key, required this.currenciesFuture})
      : super(key: key);

  @override
  _CurrencyListScreenState createState() => _CurrencyListScreenState();
}

class _CurrencyListScreenState extends State<CurrencyListScreen> {
  final PreferencesService _preferencesService = PreferencesService();
  List<Currency> _selectedCurrencies = [];

  @override
  void initState() {
    super.initState();
    widget.currenciesFuture.then((allCurrencies) {
      _initializeSelectedCurrencies(allCurrencies);
    });
  }

  Future<void> _initializeSelectedCurrencies(
      List<Currency> allCurrencies) async {
    final List<String> savedCurrencyNames =
        await _preferencesService.getSelectedCurrencies();

    if (savedCurrencyNames.isEmpty) {
      final List<String> coreCurrencyNames = allCurrencies
          .where((currency) => currency.isCore)
          .map((currency) => currency.currencyCode)
          .toList();
      await _preferencesService.setSelectedCurrencies(coreCurrencyNames);
      setState(() {
        _selectedCurrencies =
            allCurrencies.where((currency) => currency.isCore).toList();
      });
    } else {
      setState(() {
        _selectedCurrencies = allCurrencies
            .where((currency) =>
                savedCurrencyNames.contains(currency.currencyCode))
            .toList();
      });
    }
  }

  Future<void> _navigateToAddCurrencyPage(List<Currency> allCurrencies) async {
    final List<Currency>? newCurrencies = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddCurrencyPage(existingCurrencies: allCurrencies),
      ),
    );

    if (newCurrencies != null && newCurrencies.isNotEmpty) {
      // Update the list of selected currencies in SharedPreferences
      await _preferencesService.setSelectedCurrencies(
        newCurrencies.map((c) => c.currencyCode).toList(),
      );

      // Update the local list of currencies to display
      setState(() {
        _selectedCurrencies = newCurrencies;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Currency>>(
      future: widget.currenciesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching currencies'));
        } else if (snapshot.hasData) {
          return Scaffold(
            body: CustomScrollView(
              slivers: <Widget>[
                const SliverAppBar(
                  expandedHeight: 100.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text('Currency List'),
                    // Add any additional AppBar customization here
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final Currency currency = snapshot.data![index];
                      return CurrencyListItem(currency: currency);
                    },
                    childCount: snapshot.data!.length,
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _navigateToAddCurrencyPage(snapshot.data!),
              tooltip: 'Add Currency',
              child: const Icon(Icons.add),
            ),
          );
        } else {
          return Center(child: Text('No currencies available'));
        }
      },
    );
  }
}
