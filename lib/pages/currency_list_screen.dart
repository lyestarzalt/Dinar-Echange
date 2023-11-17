import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/unified_currency_service.dart';
import '../models/currency.dart';
import 'add_currency_page.dart';
import '../services/preferences_service.dart';
import 'conversion_page.dart'; // Import your CurrencyConverterPage
import 'package:dinar_watch/theme_manager.dart';

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
    // Add your logic to refresh the currency data here
    await _loadInitialCurrencies(); // Reload the currencies
    // Optionally, you can show a toast or snackbar to indicate that the refresh is complete.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Currencies refreshed'),
      ),
    );
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

  String _formatCurrencyValue(double value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currency List')),
      body: RefreshIndicator(
        color: Theme.of(context).primaryColor, // Customize the color
        backgroundColor: Theme.of(context).backgroundColor,
        onRefresh: _refreshCurrencies,
        child: ListView.separated(
          itemCount: _currencies.length,
          separatorBuilder: (context, index) =>
              Divider(), // Divider between each item
          itemBuilder: (context, index) {
            final Currency currency = _currencies[index];
            return ListTile(
              onTap: () {
                // Navigate to CurrencyConverterPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CurrencyConverterPage(currency: currency),
                  ),
                );
              },
              leading: Container(
                width: 40,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    currency.name.substring(0, 2),
                    style: ThemeManager.currencyCodeStyle(context),
                  ),
                ),
              ),
              title: Hero(
                tag: 'hero_currency_${currency.name}',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    currency.name,
                    style: ThemeManager.currencyCodeStyle(context),
                  ),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 70, // Width of the container for the currency values
                    child: Text(
                      _formatCurrencyValue(currency.buy), // Buy value
                      style: ThemeManager.moneyNumberStyle(context),
                      textAlign: TextAlign.left, // Align text to the left
                    ),
                  ),
                  Text(
                    " DZD", // Currency unit
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface, // Adapts to theme
                    ),
                  ),
                  const SizedBox(width: 15), // Space between DZD and arrow icon
                  Icon(
                    Icons.arrow_forward_ios, // Small arrow icon
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                    size: 16,
                  ),
                ],
              ),
            );
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
