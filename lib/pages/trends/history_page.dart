import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:dinar_watch/models/currency_history.dart';
import 'package:dinar_watch/theme/theme_manager.dart';
import 'package:dinar_watch/widgets/history/currency_menu.dart';
import 'package:dinar_watch/widgets/history/time_span_buttons.dart';
import 'package:animations/animations.dart';
import 'package:dinar_watch/data/repositories/main_repository.dart';
import 'package:logger/logger.dart';
import 'package:dinar_watch/widgets/error_message.dart';
import 'package:dinar_watch/widgets/history/line_graph.dart';

class HistoryPage extends StatefulWidget {
  final Future<List<Currency>> currenciesFuture;

  const HistoryPage({super.key, required this.currenciesFuture});

  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  var logger = Logger(printer: PrettyPrinter());
  bool _isLoading = true;
  late List<Currency> coreCurrencies;
  late double _maxYValue, _minYValue, _midYValue;
  double _maxX = 0;
  final int _timeSpan = 30; // Default to 1 month
  final String _selectedCurrencyCode = 'EUR'; // Default currency
  Currency? _selectedCurrency;
  List<CurrencyHistoryEntry> filteredHistoryEntries = [];
  int _touchedIndex = -1;
  String _selectedValue = ''; // Holds the selected spot's value
  String _selectedDate = ''; // Holds the selected spot's date
  final MainRepository _mainRepository = MainRepository();

  @override
  void initState() {
    super.initState();
    _initializeCurrencyHistory(widget.currenciesFuture);
  }

  Future<void> _initializeCurrencyHistory(
      Future<List<Currency>> currenciesFuture) async {
    try {
      setState(() => _isLoading = true);
      final List<Currency> currencies = await currenciesFuture;
      coreCurrencies = currencies.where((currency) => currency.isCore).toList();

      // Select the default currency or the first one as a fallback
      _selectedCurrency = coreCurrencies.firstWhere(
        (currency) => currency.currencyCode == _selectedCurrencyCode,
        orElse: () => coreCurrencies.first,
      );

      // Load the history for the selected currency
      await _loadCurrencyHistory();
    } catch (error) {
      logger.e('Error initializing currency history: $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCurrencyHistory() async {
    try {
      Currency updatedCurrency =
          await _mainRepository.getCurrencyHistory(_selectedCurrency!);
      setState(() {
        _selectedCurrency = updatedCurrency;
        if (_selectedCurrency!.history!.isNotEmpty) {
          filteredHistoryEntries = _selectedCurrency!.history!;
          _processDataAndSetState(days: _timeSpan);
        }
      });
    } catch (error) {
      logger.e('Error loading currency history: $error');
    }
  }

  void _processDataAndSetState({int days = 30}) {
    setState(() {
      _isLoading = true;
    });

    filteredHistoryEntries = _selectedCurrency!.getFilteredHistory(days);
    final List<double> allBuyValues =
        filteredHistoryEntries.map((e) => e.buy).toList();
    const bufferPercent = 0.02; // 2% buffer
    final maxDataValue = allBuyValues.reduce(math.max);
    final minDataValue = allBuyValues.reduce(math.min);
    final bufferValue = (maxDataValue - minDataValue) * bufferPercent;
    setState(() {
      _selectedValue = filteredHistoryEntries.isNotEmpty
          ? filteredHistoryEntries.last.buy.toStringAsFixed(2)
          : '';
      _selectedDate = filteredHistoryEntries.isNotEmpty
          ? DateFormat('dd/MM/yyyy').format(filteredHistoryEntries.last.date)
          : '';
      _maxYValue = maxDataValue + bufferValue;
      _minYValue = minDataValue - bufferValue;
      _midYValue = (_maxYValue + _minYValue) / 2;
      _maxX = filteredHistoryEntries.length.toDouble() - 1;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Trends'),
        shadowColor: Theme.of(context).colorScheme.shadow,
      ),
      floatingActionButton: OpenContainer(
        transitionType: ContainerTransitionType.fade,
        openBuilder: (BuildContext context, VoidCallback _) {
          return CurrencyMenu(
            coreCurrencies: coreCurrencies,
            onCurrencySelected: (Currency selectedCurrency) {
              setState(() {
                _selectedCurrency = selectedCurrency;
                _loadCurrencyHistory();
              });
            },
            parentContext: context,
          );
        },
        closedElevation: 6.0,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        closedColor: Theme.of(context).colorScheme.secondary,
        closedBuilder: (BuildContext context, VoidCallback openContainer) {
          return SizedBox(
            height: 56.0,
            width: 56.0,
            child: Center(
              child: Icon(
                Icons.menu,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          );
        },
      ),
      body: _isLoading
          ? Center(
              child: LinearProgressIndicator(
                backgroundColor:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation(
                    Theme.of(context).colorScheme.primary),
              ),
            )
          : _selectedCurrency != null
              ? _buildCurrencyContent(context)
              : const Center(
                  child:
                      ErrorMessage(message: "Currency data is not available")),
    );
  }

  Widget _buildCurrencyContent(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isLoading)
              LinearProgressIndicator(
                backgroundColor:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation(
                    Theme.of(context).colorScheme.primary),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '1 ${_selectedCurrency!.currencyCode} = $_selectedValue',
                style: ThemeManager.moneyNumberStyle(context),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _selectedDate,
                style: ThemeManager.currencyCodeStyle(context),
              ),
            ),
            const SizedBox(height: 16),
            AspectRatio(
                aspectRatio: 1.0,
                child: LineChart(
                  buildMainData(
                    context: context,
                    minYValue: _minYValue,
                    midYValue: _midYValue,
                    maxYValue: _maxYValue,
                    touchedIndex: _touchedIndex,
                    maxX: _maxX,
                    historyEntries: filteredHistoryEntries,
                    onIndexChangeCallback:
                        (int index, List<CurrencyHistoryEntry> entries) {
                      setState(() {
                        _touchedIndex = index;
                        _selectedValue =
                            '${entries[index].buy.toStringAsFixed(2)} DZD';
                        _selectedDate = DateFormat('dd/MM/yyyy')
                            .format(entries[index].date);
                      });
                    },
                  ),
                )),
            const SizedBox(height: 20),
            TimeSpanButtons(
                onTimeSpanSelected: (days) =>
                    _processDataAndSetState(days: days)),
          ],
        ),
      ),
    );
  }
}
