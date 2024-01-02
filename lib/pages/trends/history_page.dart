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

class HistoryPage extends StatefulWidget {
  final Future<List<Currency>> currenciesFuture;

  const HistoryPage({super.key, required this.currenciesFuture});

  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  late List<Currency> coreCurrencies;
  late double _maxYValue, _minYValue, _midYValue;
  double _maxX = 0;
  bool _isLoading = true;
  int _timeSpan = 180; // Default to 1 month
  final String _selectedCurrencyCode = 'EUR'; // Default currency
  late Currency _selectedCurrency;
  late List<CurrencyHistoryEntry> filteredHistoryEntries;
  var logger = Logger(printer: PrettyPrinter());
  int _touchedIndex = -1;
  String _selectedValue = ''; // Holds the selected spot's value
  String _selectedDate = ''; // Holds the selected spot's date
  final MainRepository _mainRepository =
      MainRepository(); // Assuming this repository exists

  @override
  void initState() {
    super.initState();
    _initializeCurrencyHistory(widget.currenciesFuture);
  }

  Future<void> _initializeCurrencyHistory(
      Future<List<Currency>> currenciesFuture) async {
    final List<Currency> currencies = await currenciesFuture;

    coreCurrencies = currencies.where((currency) => currency.isCore).toList();
    _selectedCurrency = coreCurrencies.firstWhere(
      (currency) => currency.currencyCode == _selectedCurrencyCode,
      orElse: () => coreCurrencies.first,
    );

    _loadCurrencyHistory(_selectedCurrency.currencyCode);
  }

  Future<void> _loadCurrencyHistory(String currencyCode) async {
    setState(() => _isLoading = true);

    _selectedCurrency =
        await _mainRepository.getCurrencyHistory(_selectedCurrency);
    if (_selectedCurrency.history != null) {
      filteredHistoryEntries = _selectedCurrency.history!;
      _processDataAndSetState(days: _timeSpan);
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _processDataAndSetState({int days = 30}) {
    _isLoading = true;

    filteredHistoryEntries = _selectedCurrency.getFilteredHistory(days);
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

  FlTitlesData _buildTitlesData(BuildContext context, double minYValue,
      double midYValue, double maxYValue) {
    return FlTitlesData(
      rightTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          interval: 1,
          getTitlesWidget: (value, meta) => value == minYValue ||
                  value == midYValue.round() ||
                  value == maxYValue
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    value.toInt().toString(),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                    textAlign: TextAlign.left,
                  ),
                )
              : Container(),
        ),
      ),
      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  List<LineChartBarData> _buildLineBarsData(
      BuildContext context, List<CurrencyHistoryEntry> filteredHistoryEntries) {
    return [
      LineChartBarData(
        spots: filteredHistoryEntries
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value.buy))
            .toList(),
        isCurved: false,
        barWidth: 5,
        color: Theme.of(context).colorScheme.secondary,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      ),
    ];
  }

  void onIndexChange(int newIndex) {
    if (newIndex >= 0 && newIndex < filteredHistoryEntries.length) {
      setState(() {
        _touchedIndex = newIndex;
        _selectedValue =
            filteredHistoryEntries[newIndex].buy.toStringAsFixed(2) + ' DZD';
        _selectedDate = DateFormat('dd/MM/yyyy')
            .format(filteredHistoryEntries[newIndex].date);
      });
    }
  }

  LineTouchData _buildLineTouchData(
      BuildContext context, int touchedIndex, Function(int) onIndexChange) {
    return LineTouchData(
      touchCallback: (event, touchResponse) {
        if (event.isInterestedForInteractions &&
            touchResponse?.lineBarSpots != null) {
          final spot = touchResponse!.lineBarSpots!.first;
          final newIndex = spot.x.toInt();
          if (newIndex != touchedIndex) {
            onIndexChange(newIndex);
          }
        }
      },
      handleBuiltInTouches: true,
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Colors.transparent,
        tooltipRoundedRadius: 0,
        getTooltipItems: (List<LineBarSpot> touchedSpots) {
          return touchedSpots
              .map((spot) => const LineTooltipItem(
                    '', // Empty string for tooltip content
                    TextStyle(
                        color: Colors.transparent), // Transparent text style
                  ))
              .toList();
        },
      ),
      getTouchedSpotIndicator:
          (LineChartBarData barData, List<int> spotIndexes) {
        return spotIndexes.map((index) {
          return TouchedSpotIndicatorData(
            const FlLine(color: Colors.transparent),
            FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6, // Adjust the size of the dot
                  color: Theme.of(context)
                      .colorScheme
                      .secondary, // Color of the dot
                  strokeColor: Colors.transparent, // Border color of the dot
                );
              },
            ),
          );
        }).toList();
      },
    );
  }

  LineChartData _mainData(BuildContext context) {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: _buildTitlesData(context, _minYValue, _midYValue, _maxYValue),
      extraLinesData: ExtraLinesData(
        horizontalLines: [_minYValue, _midYValue.round().toDouble(), _maxYValue]
            .map((yValue) => HorizontalLine(
                y: yValue,
                color:
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                strokeWidth: 1,
                dashArray: [5]))
            .toList(),
      ),
      lineTouchData: _buildLineTouchData(context, _touchedIndex, onIndexChange),
      borderData: FlBorderData(show: false),
      maxX: _maxX,
      maxY: _maxYValue,
      minY: _minYValue,
      lineBarsData: _buildLineBarsData(context, filteredHistoryEntries),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    double? scrolledUnderElevation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Trends'),
        scrolledUnderElevation: scrolledUnderElevation,
        shadowColor: colorScheme.shadow,
      ),
      floatingActionButton: OpenContainer(
        transitionType: ContainerTransitionType.fade,
        openBuilder: (BuildContext context, VoidCallback _) {
          return CurrencyMenu(
            coreCurrencies: coreCurrencies,
            onCurrencySelected: (Currency selectedCurrency) {
              setState(() {
                _selectedCurrency = selectedCurrency;
                _loadCurrencyHistory(_selectedCurrency.currencyCode);
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (!_isLoading) ...[
                Text(
                  '1 ${_selectedCurrency.currencyCode} = $_selectedValue',
                  style: ThemeManager.moneyNumberStyle(context),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedDate,
                  style: ThemeManager.currencyCodeStyle(context),
                ),
                const SizedBox(height: 16),
                AspectRatio(
                  aspectRatio: 1.2,
                  child: LineChart(_mainData(context)),
                ),
                const SizedBox(height: 16),
                TimeSpanButtons(
                    onTimeSpanSelected: (dayz) =>
                        _processDataAndSetState(days: dayz)),
              ] else
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
