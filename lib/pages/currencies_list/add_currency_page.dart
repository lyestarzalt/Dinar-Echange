import 'package:flutter/material.dart';
import '../../models/currency.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dinar_watch/widgets/flag_container.dart';

class AddCurrencyPage extends StatefulWidget {
  final List<Currency> existingCurrencies;

  const AddCurrencyPage({super.key, required this.existingCurrencies});

  @override
  AddCurrencyPageState createState() => AddCurrencyPageState();
}

class AddCurrencyPageState extends State<AddCurrencyPage> {
  List<Currency> selectedCurrencies = [];
  List<Currency> filteredCurrencies = [];
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();

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
    List<Currency> sortedCurrencies = List<Currency>.from(selectedCurrencies);
    sortedCurrencies.addAll(filteredCurrencies
        .where((currency) => !selectedCurrencies.contains(currency)));

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: TextField(
          controller: searchController,
          focusNode: searchFocusNode,
          decoration: const InputDecoration(
            hintText: 'Search',
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: FloatingActionButton(
              mini: true,
              onPressed: _addSelectedCurrencies,
              tooltip: 'Add Selected Currencies',
              child: const Icon(Icons.check),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filteredCurrencies.length,
              itemBuilder: (context, index) {
                Currency currency = filteredCurrencies[index];
                bool isSelected = selectedCurrencies.contains(currency);
                return _buildCurrencyListItem(currency, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyListItem(Currency currency, bool isSelected) {
    return ListTile(
      leading: FlagContainer(
        imageUrl: currency.flag,
        width: 50,
        height: 40,
        borderRadius: BorderRadius.circular(1),
      ),
      title: Row(
        children: [
          Text(currency.currencyCode),
          const SizedBox(width: 10),
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
  }
}
