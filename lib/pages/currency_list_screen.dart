import 'package:flutter/material.dart';
import '../data/repositories/unified_currency_service.dart';
import '../models/currency.dart';
import 'add_currency_page.dart';
import '../services/preferences_service.dart';
import 'package:dinar_watch/widgets/currency_list_item.dart';

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

  Future<void> _refreshCurrencies() async {
    await _loadInitialCurrencies();
    await Future.delayed(const Duration(seconds: 1)); //Firestore is too fast!

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Currencies refreshed'),
        ),
      );
    }
  }

  Future<void> _loadInitialCurrencies() async {
    final List<String> savedCurrencyNames =
        await _preferencesService.getSelectedCurrencies();
    _allCurrencies = await _unifiedCurrencyService.getUnifiedCurrencies();

    if (savedCurrencyNames.isEmpty) {
      final List<String> coreCurrencyNames = _allCurrencies
          .where((currency) => currency.isCore)
          .map((currency) => currency.currencyCode)
          .toList();

      await _preferencesService.setSelectedCurrencies(coreCurrencyNames);
    }

    setState(() {
      _currencies = _allCurrencies
          .where(
              (currency) => savedCurrencyNames.contains(currency.currencyCode))
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
        newCurrencies.map((c) => c.currencyCode).toList(),
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
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.secondary,
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        strokeWidth: 2.0,
        // Other properties as needed...
        onRefresh: _refreshCurrencies,
        child: ListView.separated(
          itemCount: _currencies.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final Currency currency = _currencies[index];
            return CurrencyListItem(currency: currency); // Use the new widget
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddCurrencyPage,
        tooltip: 'Add Currency',
        child: const Icon(Icons.add),
      ),
    );
  }
}
