import 'package:flutter/material.dart';
import '../models/currency.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    filteredCurrencies = widget.existingCurrencies;
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
          .where((currency) =>
              currency.currencyCode.toLowerCase().contains(searchTerm) ||
              (currency.currencyName?.toLowerCase().contains(searchTerm) ??
                  false))
          .toList();
    });
  }

  void _loadSelectedCurrencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedCurrencyNames =
        prefs.getStringList('selectedCurrencies') ?? [];
    setState(() {
      selectedCurrencies = widget.existingCurrencies
          .where(
              (currency) => savedCurrencyNames.contains(currency.currencyCode))
          .toList();
    });
  }

  void _saveSelectedCurrencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> currencyNames =
        selectedCurrencies.map((c) => c.currencyCode).toList();
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
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Transform.scale(
          scale: 0.8,
          child: FloatingActionButton(
            onPressed: _addSelectedCurrencies,
            tooltip: 'Add Selected Currencies',
            child: const Icon(Icons.check),
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
              decoration: const InputDecoration(
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
                  leading: currency.flag != null
                      ? CachedNetworkImage(
                          imageUrl: currency.flag!,
                          width: 30,
                          height: 20,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        )
                      : SizedBox(width: 30),
                  title: Row(
                    children: [
                      Text(currency.currencyCode),
                      SizedBox(width: 10),
                      Expanded(child: Text(currency.currencyName ?? '')),
                    ],
                  ),
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
