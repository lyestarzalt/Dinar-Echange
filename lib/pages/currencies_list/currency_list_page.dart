import 'package:flutter/material.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:dinar_watch/services/preferences_service.dart';
import 'package:dinar_watch/pages/currencies_list/add_currency_page.dart';
import 'package:dinar_watch/widgets/currency_list_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        _selectedCurrencies = savedCurrencyNames
            .map((code) => allCurrencies
                .firstWhere((currency) => currency.currencyCode == code))
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
      await _preferencesService.setSelectedCurrencies(
        newCurrencies.map((c) => c.currencyCode).toList(),
      );

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

  Future<void> _handleRefresh() async {
    // fake it.. for now
    await Future.delayed(const Duration(seconds: 2));
  }

  bool shadowColor = false;
  double? scrolledUnderElevation;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<Currency>>(
      future: widget.currenciesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text(
                  AppLocalizations.of(context)!.error_fetching_currencies));
        } else if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.currency_list),
              scrolledUnderElevation: scrolledUnderElevation,
              shadowColor: shadowColor ? colorScheme.shadow : null,
            ),
            body: Padding(
                padding: const EdgeInsets.fromLTRB(1, 0, 1, 0),
                child: RefreshIndicator(
                  onRefresh: () => _handleRefresh(),
                  child: ReorderableListView.builder(
                    itemCount: _selectedCurrencies.length,
                    itemBuilder: (context, index) {
                      final Currency currency = _selectedCurrencies[index];
                      return CurrencyListItem(
                        key: ValueKey(currency.currencyCode),
                        currency: currency,
                      );
                    },
                    onReorder: (int oldIndex, int newIndex) {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      setState(() {
                        final Currency item =
                            _selectedCurrencies.removeAt(oldIndex);
                        _selectedCurrencies.insert(newIndex, item);
                      });
                      _saveCurrencyOrder();
                    },
                  ),
                )),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _navigateToAddCurrencyPage(snapshot.data!),
              tooltip: AppLocalizations.of(context)!.add_currencies,
              child: const Icon(Icons.add),
            ),
          );
        } else {
          return Center(
              child: Text(AppLocalizations.of(context)!.no_currencies));
        }
      },
    );
  }
}
