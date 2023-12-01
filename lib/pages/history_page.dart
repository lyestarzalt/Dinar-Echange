import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:dinar_watch/data/services/currency_firestore_service.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:dinar_watch/models/currency_history.dart';
import 'package:dinar_watch/theme_manager.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late CurrencyHistory _currencyHistory;
  late List<Currency> _filteredHistory;

  late double _maxYValue, _minYValue, _midYValue;
  double _maxX = 0;
  bool _isLoading = true;
  int _timeSpan = 30; // default to 1 month
  String _selectedCurrency = 'EUR'; // default currency
  int _touchedIndex = -1;
  String _selectedValue = ''; // Holds the selected spot's value
  String _selectedDate = ''; // Holds the selected spot's date

  @override
  void initState() {
    super.initState();
    _loadCurrencyHistory(_selectedCurrency);
  }

  Future<void> _loadCurrencyHistory(String currency) async {
    print('Loading currency history for $currency');
    _currencyHistory = await FirestoreService().fetchCurrencyHistory(currency);
    _processDataAndSetState();
  }

  void _processDataAndSetState() {
    final cutOffDate = DateTime.now().subtract(Duration(days: _timeSpan));

    final filteredHistory = _currencyHistory.history
        .where((data) => data.date.isAfter(cutOffDate))
        .toList();

    print(
        'Number of data points for $_timeSpan days: ${filteredHistory.length}');

    final List<double> allBuyValues =
        filteredHistory.map((data) => data.buy).toList();
    final bufferPercentX = 0.05; // 5% buffer
    final bufferValueX = filteredHistory.length * bufferPercentX;

// Set a buffer value that will be used to extend the max and min values by a certain percentage.
    const bufferPercent = 0.02; // 2% buffer
    final maxDataValue = allBuyValues.reduce(math.max);
    final minDataValue = allBuyValues.reduce(math.min);
    final bufferValue = (maxDataValue - minDataValue) * bufferPercent;

    setState(() {
      _selectedValue = filteredHistory.last.buy.toString();
      _filteredHistory = filteredHistory;
      _isLoading = false;
      _maxYValue = maxDataValue + bufferValue; // Add buffer to the max value
      _minYValue =
          minDataValue - bufferValue; // Subtract buffer from the min value
      _midYValue = (_maxYValue + _minYValue) / 2;
      _maxX = filteredHistory.length - 1; // Apply buffer to maxX
    });
    print('maxX: $_maxX, maxY: $_maxYValue, minY: $_minYValue');
  }

  void _onTimeSpanButtonClicked(int days) {
    setState(() {
      _timeSpan = days;
      _isLoading = true;
    });
    _processDataAndSetState();
  }

  LineChartData _mainData() {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: 1,
            getTitlesWidget: (value, meta) => value == _minYValue ||
                    value == _midYValue ||
                    value == _maxYValue
                ? Text('${value.toStringAsFixed(2)}',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                    textAlign: TextAlign.right)
                : Container(),
          ),
        ),
        bottomTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      extraLinesData: ExtraLinesData(
        horizontalLines: [_minYValue, _midYValue, _maxYValue]
            .map((yValue) => HorizontalLine(
                y: yValue,
                color:
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                strokeWidth: 1,
                dashArray: [5]))
            .toList(),
      ),
      lineTouchData: LineTouchData(
        touchCallback: (event, touchResponse) {
          if (event.isInterestedForInteractions &&
              touchResponse?.lineBarSpots != null) {
            final spot = touchResponse!.lineBarSpots!.first;
            final newIndex = spot.x.toInt();
            if (newIndex != _touchedIndex) {
              setState(() {
                _selectedValue = '${spot.y.toStringAsFixed(2)} DZD';
                _selectedDate = DateFormat('dd/MM/yyyy')
                    .format(_currencyHistory.history[newIndex].date);
                _touchedIndex = newIndex;
              });
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
            if (index == _touchedIndex) {
              // Check if the index matches the touched index
              return const TouchedSpotIndicatorData(
                FlLine(color: Colors.transparent),
                FlDotData(show: true), // Show the dot
              );
            } else {
              return const TouchedSpotIndicatorData(
                FlLine(color: Colors.transparent),
                FlDotData(show: false), // Hide the dot for other indexes
              );
            }
          }).toList();
        },
      ),
      borderData: FlBorderData(show: false),
      maxX: _maxX,
      maxY: _maxYValue,
      minY: _minYValue,
      lineBarsData: [
        LineChartBarData(
          spots: _filteredHistory
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Currency History'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // Refresh action
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align to start
            children: [
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
                  child: LineChart(_mainData()),
                ),
                const SizedBox(height: 16),
                _buildTimeSpanButtons(),
              ] else
                const Expanded(
                    child: Center(child: CircularProgressIndicator())),
            ],
          ),
        ),
      );
  Widget _buildTimeSpanButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTimeSpanButton('1M', 30),
        _buildTimeSpanButton('6M', 180),
        _buildTimeSpanButton('1Y', 365),
        _buildTimeSpanButton('2Y', 730),
      ],
    );
  }

  Widget _buildTimeSpanButton(String label, int days) {
    return InkWell(
      onTap: () {
        setState(() {
          _timeSpan = days;
        });
        _onTimeSpanButtonClicked(days);
      },
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
