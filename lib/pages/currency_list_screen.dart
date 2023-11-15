import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/unified_currency_service.dart';
import '../models/currency.dart';
import 'add_currency_page.dart';
import '../services/preferences_service.dart';
import 'conversion_page.dart'; // Import your CurrencyConverterPage

// Use Dart documentation style for comments.
/// Displays a list of currencies.
class CurrencyListScreen extends StatefulWidget {
  const CurrencyListScreen({super.key});

  @override
  _CurrencyListScreenState createState() => _CurrencyListScreenState();
}

class _CurrencyListScreenState extends State<CurrencyListScreen> {
  final UnifiedCurrencyService _unifiedCurrencyService =
      UnifiedCurrencyService();
  final PreferencesService _preferencesService = PreferencesService();
  List<Currency> _currencies = [];
  List<Currency> _allCurrencies = [];

  @override
  void initState() {
    super.initState();
    _loadInitialCurrencies();
  }

  Future<void> _loadInitialCurrencies() async {
    final List<String> savedCurrencyNames =
        await _preferencesService.getSelectedCurrencies();
    _allCurrencies = await _unifiedCurrencyService.getUnifiedCurrencies();

    if (savedCurrencyNames.isEmpty) {
      final List<String> coreCurrencyNames = _allCurrencies
          .where((currency) => currency.isCore)
          .map((currency) => currency.name)
          .toList();

      await _preferencesService.setSelectedCurrencies(coreCurrencyNames);
    }

    setState(() {
      _currencies = _allCurrencies
          .where((currency) => savedCurrencyNames.contains(currency.name))
          .toList();
    });
  }

  Future<void> _navigateToAddCurrencyPage() async {
    final List<Currency>? newCurrencies = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddCurrencyPage(existingCurrencies: _allCurrencies),
      ),
    );

    if (newCurrencies != null && newCurrencies.isNotEmpty) {
      // Update the list of selected currencies in SharedPreferences
      await _preferencesService.setSelectedCurrencies(
        newCurrencies.map((c) => c.name).toList(),
      );

      // Update the local list of currencies to display
      setState(() {
        _currencies = newCurrencies;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currency List')),
      body: ListView.builder(
        itemCount: _currencies.length,
        itemBuilder: (context, index) {
          final Currency currency = _currencies[index];
          return ListTile(
            onTap: () {
              // Handle tap on ListTile
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CurrencyConverterPage(currency: currency)));
            },
            title: Hero(
              // Wrap the currency name in a Hero widget
              tag: 'hero_currency_${currency.name}',
              child: Material(
                color: Colors.transparent,
                child: Text(currency.name),
              ),
            ),
            subtitle: Text(
                'Buy: ${currency.buy}, Sell: ${currency.sell}, Date: ${DateFormat('yyyy-MM-dd').format(currency.date)}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddCurrencyPage,
        tooltip: 'Add Currency',
        child: const Icon(Icons.add),
      ),
    );
  }
}
