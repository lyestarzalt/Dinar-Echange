import 'package:flutter/material.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:dinar_watch/services/preferences_service.dart';
import 'package:dinar_watch/pages/currencies_list/add_currency_page.dart';
import 'package:dinar_watch/widgets/currency_list_item.dart';

class CurrencyListScreen extends StatefulWidget {
  final Future<List<Currency>> currenciesFuture;

  const CurrencyListScreen({super.key, required this.currenciesFuture});

  @override
  CurrencyListScreenState createState() => CurrencyListScreenState();
}

class CurrencyListScreenState extends State<CurrencyListScreen> {
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

  Future<void> _saveCurrencyOrder() async {
    final List<String> currencyOrder =
        _selectedCurrencies.map((currency) => currency.currencyCode).toList();
    await _preferencesService.setSelectedCurrencies(currencyOrder);
  }

  bool shadowColor = false; // You can customize this as per your requirement
  double?
      scrolledUnderElevation; // You can customize this as per your requirement
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<Currency>>(
      future: widget.currenciesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching currencies'));
        } else if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Currency List'),
              scrolledUnderElevation: scrolledUnderElevation,
              shadowColor: shadowColor ? colorScheme.shadow : null,
            ),
            body: Padding(
                padding: const EdgeInsets.fromLTRB(1, 0, 1, 0),
                child: ReorderableListView.builder(
                  itemCount: _selectedCurrencies
                      .length, // Length of your currency list
                  itemBuilder: (context, index) {
                    final Currency currency = _selectedCurrencies[index];
                    return CurrencyListItem(
                      key: ValueKey(
                          currency.currencyCode), // Unique key for the item
                      currency: currency,
                    );
                  },
                  onReorder: (int oldIndex, int newIndex) {
                    // Adjust the index if necessary
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    setState(() {
                      // Update the order of currencies
                      final Currency item =
                          _selectedCurrencies.removeAt(oldIndex);
                      _selectedCurrencies.insert(newIndex, item);

                      // Save the new order (assuming you have implemented this)
                      _saveCurrencyOrder();
                    });
                  },
                )),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _navigateToAddCurrencyPage(snapshot.data!),
              tooltip: 'Add Currency',
              child: const Icon(Icons.add),
            ),
          );
        } else {
          return const Center(child: Text('No currencies available'));
        }
      },
    );
  }
}
