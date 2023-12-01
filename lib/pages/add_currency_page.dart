import 'package:flutter/material.dart';
import '../models/currency.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCurrencyPage extends StatefulWidget {
  final List<Currency> existingCurrencies;

  const AddCurrencyPage({super.key, required this.existingCurrencies});

  @override
  _AddCurrencyPageState createState() => _AddCurrencyPageState();
}

class _AddCurrencyPageState extends State<AddCurrencyPage> {
  List<Currency> selectedCurrencies = [];
  List<Currency> filteredCurrencies = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredCurrencies = widget.existingCurrencies; // Start with all currencies
    _loadSelectedCurrencies();
    searchController.addListener(_filterCurrencies);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterCurrencies() {
    String searchTerm = searchController.text.toLowerCase();
    setState(() {
      filteredCurrencies = widget.existingCurrencies
          .where((currency) => currency.currencyCode.toLowerCase().contains(searchTerm))
          .toList();
    });
  }

  void _loadSelectedCurrencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedCurrencyNames =
        prefs.getStringList('selectedCurrencies') ?? [];
    setState(() {
      // Initialize with all existing currencies marked as selected if they are in saved preferences
      selectedCurrencies = widget.existingCurrencies
          .where((currency) => savedCurrencyNames.contains(currency.currencyCode))
          .toList();
    });
  }

  void _saveSelectedCurrencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> currencyNames = selectedCurrencies.map((c) => c.currencyCode).toList();
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
        // Other AppBar configurations...
      ),
      floatingActionButton: Padding(
        padding:
            EdgeInsets.only(top: 0), // Adjust this value to move FAB upwards
        child: Transform.scale(
          scale: 0.8, // Adjust the size of the FAB
          child: FloatingActionButton(
            onPressed: _addSelectedCurrencies,
            child: const Icon(Icons.check),
            tooltip: 'Add Selected Currencies',
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 30, 5, 0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCurrencies.length,
              itemBuilder: (context, index) {
                Currency currency = filteredCurrencies[index];
                bool isSelected = selectedCurrencies.contains(currency);
                return ListTile(
                  title: Text(currency.currencyCode),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null) {
                          if (value) {
                            selectedCurrencies.add(currency);
                          } else {
                            selectedCurrencies.remove(currency);
                          }
                        }
                      });
                    },
                  ),
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
          ),
        ],
      ),
    );
  }
}
