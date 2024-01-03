import 'package:flutter/material.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:dinar_watch/pages/currencies_list/add_currency_page.dart';
import 'package:dinar_watch/widgets/currency_list_item.dart';
import 'package:dinar_watch/services/currency_serivice.dart';

class CurrencyListScreen extends StatefulWidget {
  final Future<List<Currency>> currenciesFuture;

  const CurrencyListScreen({super.key, required this.currenciesFuture});

  @override
  CurrencyListScreenState createState() => CurrencyListScreenState();
}

class CurrencyListScreenState extends State<CurrencyListScreen> {
  late CurrencyService _currencyService;
  List<Currency> _selectedCurrencies = [];
  @override
  void initState() {
    super.initState();
    _currencyService = CurrencyService(widget.currenciesFuture);
    _initializeSelectedCurrencies();
  }

  Future<void> _initializeSelectedCurrencies() async {
    _selectedCurrencies = await _currencyService.loadSelectedCurrencies();
    setState(() {});
  }

  Future<void> _navigateToAddCurrencyPage() async {
    final List<Currency>? newCurrencies = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddCurrencyPage(existingCurrencies: _selectedCurrencies),
      ),
    );

    if (newCurrencies != null && newCurrencies.isNotEmpty) {
      _selectedCurrencies = await _currencyService.addCurrency(newCurrencies);
      setState(() {});
    }
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
                      key: ValueKey(currency.currencyCode),
                      currency: currency,
                    );
                  },
                  onReorder: (int oldIndex, int newIndex) {
                    _currencyService.reorderCurrencies(oldIndex, newIndex);
                    setState(() {});
                    _currencyService.saveCurrencyOrder();
                    print("Order saved"); // Debug print
                  },
                )),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _navigateToAddCurrencyPage(),
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
