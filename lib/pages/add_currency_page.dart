import 'package:flutter/material.dart';
import '../models/currency.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCurrencyPage extends StatefulWidget {
  final List<Currency> existingCurrencies;

  AddCurrencyPage({required this.existingCurrencies});

  @override
  _AddCurrencyPageState createState() => _AddCurrencyPageState();
}

class _AddCurrencyPageState extends State<AddCurrencyPage> {
  List<Currency> selectedCurrencies = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedCurrencies();
  }

  void _loadSelectedCurrencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedCurrencyNames =
        prefs.getStringList('selectedCurrencies') ?? [];
    setState(() {
      // Initialize with all existing currencies marked as selected if they are in saved preferences
      selectedCurrencies = widget.existingCurrencies
          .where((currency) => savedCurrencyNames.contains(currency.name))
          .toList();
    });
  }

  void _saveSelectedCurrencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> currencyNames = selectedCurrencies.map((c) => c.name).toList();
    await prefs.setStringList('selectedCurrencies', currencyNames);
  }

  void _addSelectedCurrencies() {
    _saveSelectedCurrencies();
    Navigator.pop(context, selectedCurrencies);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Extra Currencies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _addSelectedCurrencies,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.existingCurrencies.length,
        itemBuilder: (context, index) {
          Currency currency = widget.existingCurrencies[index];
          bool isSelected = selectedCurrencies.contains(currency);
          return ListTile(
            title: Text(currency.name),
            trailing: isSelected
                ? const Icon(Icons.check_circle)
                : const Icon(Icons.check_circle_outline),
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedCurrencies.remove(currency);
                } else {
                  selectedCurrencies.add(currency);
                }
              });
            },
          );
        },
      ),
    );
  }
}
