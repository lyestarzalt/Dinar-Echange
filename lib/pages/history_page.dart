import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:dinar_watch/models/currency_history.dart';
import 'package:dinar_watch/theme_manager.dart';
import 'package:dinar_watch/widgets/history/currency_menu.dart';
import 'package:dinar_watch/widgets/history/time_span_buttons.dart';
import 'package:animations/animations.dart';

class HistoryPage extends StatefulWidget {
  final Future<List<Currency>> currenciesFuture;

  const HistoryPage({super.key, required this.currenciesFuture});

  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late CurrencyHistory _currencyHistory;
  late List<Currency> _filteredHistory;
  late List<Currency> coreCurrencies;
  late double _maxYValue, _minYValue, _midYValue;
  double _maxX = 0;
  bool _isLoading = true;
  int _timeSpan = 30; // default to 1 month
  String _selectedCurrency = 'EUR'; // default currency
  int _touchedIndex = -1;
  String _selectedValue = ''; // Holds the selected spot's value
  String _selectedDate = ''; // Holds the selected spot's date

//
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _loadCurrencyHistory(_selectedCurrency);
  }

  void _showCurrencyMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return CurrencyMenu(
          coreCurrencies: coreCurrencies,
          onCurrencySelected: (selectedCurrency) {
            setState(() {
              _selectedCurrency = selectedCurrency;
              _loadCurrencyHistory(_selectedCurrency);
            });
          },
          parentContext: context,
        );
      },
      backgroundColor: Colors.transparent, // Make the background transparent
      isScrollControlled:
          true, // Allow the sheet to take only half of the screen
    );
  }

  Future<void> _loadCurrencyHistory(String currencyCode) async {
    final List<Currency> currencies = await widget.currenciesFuture;
    Currency? selectedCurrency;
    coreCurrencies = currencies.where((currency) => currency.isCore).toList();

    // Manually searching for the first matching currency
    for (var currency in currencies) {
      if (currency.currencyCode == currencyCode && currency.isCore) {
        selectedCurrency = currency;
        break; // Break the loop once the currency is found
      }
    }

    if (selectedCurrency != null && selectedCurrency.history != null) {
      _currencyHistory = CurrencyHistory(
        name: selectedCurrency.currencyCode,
        history: selectedCurrency.history!,
      );
      _processDataAndSetState();
    } else {
      // Handle currency not found or no history available
    }
  }

  /// Filters the last [timeSpan] days of currency history.
  ///
  /// Returns the entire history if it's shorter than [timeSpan],
  /// otherwise returns the last [timeSpan] days.

  List<Currency> _filterCurrencyHistory(int timeSpan) {
    final int historyLength = _currencyHistory.history.length;
    final int startIndex = historyLength - timeSpan;
    return historyLength <= timeSpan
        ? _currencyHistory.history
        : _currencyHistory.history.sublist(startIndex);
  }

  void _processDataAndSetState() {
    final filteredHistory = _filterCurrencyHistory(_timeSpan);

    final List<double> allBuyValues =
        filteredHistory.map((data) => data.buy).toList();
    // const bufferPercentX = 0.05; // 5% buffer
    // final bufferValueX = filteredHistory.length * bufferPercentX;

    // Set a buffer value that will be used to extend the max and min values by a certain percentage.
    const bufferPercent = 0.02; // 2% buffer
    final maxDataValue = allBuyValues.reduce(math.max);
    final minDataValue = allBuyValues.reduce(math.min);
    final bufferValue = (maxDataValue - minDataValue) * bufferPercent;

    setState(() {
      _selectedValue = filteredHistory.last.buy.toString();
      _filteredHistory = filteredHistory;
      _isLoading = false;
      _maxYValue = maxDataValue + bufferValue;
      _minYValue = minDataValue - bufferValue;
      _midYValue = (_maxYValue + _minYValue) / 2;
      _maxX = filteredHistory.length - 1;
    });
  }

  void _onTimeSpanButtonClicked(int days) {
    setState(() {
      _timeSpan = days;
      _isLoading = true;
    });
    _processDataAndSetState();
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
      BuildContext context, List<Currency> filteredHistory) {
    return [
      LineChartBarData(
        spots: filteredHistory
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
    setState(() {
      _touchedIndex = newIndex;
      _selectedValue =
          '${_filteredHistory[newIndex].buy.toStringAsFixed(2)} DZD';
      _selectedDate =
          DateFormat('dd/MM/yyyy').format(_filteredHistory[newIndex].date);
    });
  }

  LineTouchData _buildLineTouchData(BuildContext context, int touchedIndex,
      List<Currency> filteredHistory, Function(int) onIndexChange) {
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
            FlDotData(show: index == touchedIndex), // Show the dot
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
      lineTouchData: _buildLineTouchData(
          context, _touchedIndex, _filteredHistory, onIndexChange),
      borderData: FlBorderData(show: false),
      maxX: _maxX,
      maxY: _maxYValue,
      minY: _minYValue,
      lineBarsData: _buildLineBarsData(context, _filteredHistory),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: OpenContainer(
        transitionType: ContainerTransitionType.fade, // Transition type
        openBuilder: (BuildContext context, VoidCallback _) {
          return CurrencyMenu(
            coreCurrencies: coreCurrencies,
            onCurrencySelected: (selectedCurrency) {
              setState(() {
                _selectedCurrency = selectedCurrency;
                _loadCurrencyHistory(_selectedCurrency);
              });
            },
            parentContext: context,
          );
        },
        closedElevation: 6.0,
        closedShape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16), // Adjust for desired roundness
        ),
        closedColor: Theme.of(context).colorScheme.secondary,
        closedBuilder: (BuildContext context, VoidCallback openContainer) {
          return SizedBox(
            height: 56.0, // Standard FAB size
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
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            centerTitle: false,
            stretch: true,
            expandedHeight: 80.0,
            floating: false,
            pinned: true,
            actions: [],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: Text('Currency Trends'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  if (!_isLoading) ...[
                    Text(
                      '1 $_selectedCurrency = $_selectedValue',
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
                        onTimeSpanSelected: _onTimeSpanButtonClicked),
                  ] else
                    Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
