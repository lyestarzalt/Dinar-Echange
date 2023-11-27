import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/currency_history.dart';
import '../services/firebase_service.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late CurrencyHistory _currencyHistory;
  late double _maxYValue, _minYValue, _midYValue;
  bool _isLoading = true;
  int _timeSpan = 30; // default to 1 month
  String _selectedCurrency = 'EUR'; // default currency
  int _touchedIndex = -1;
  String _selectedValue = ''; // Holds the selected spot's value
  String _selectedDate = ''; // Holds the selected spot's date

  @override
  void initState() {
    super.initState();
    _loadCurrencyHistory(_selectedCurrency, _timeSpan).then((_) {
      if (_currencyHistory.history.isNotEmpty) {
        final lastIndex = _currencyHistory.history.length - 1;
        final latestDataPoint = _currencyHistory.history[lastIndex];
        setState(() {
          _selectedValue = '${latestDataPoint.sell.toStringAsFixed(2)} DZD';
          _selectedDate = DateFormat('dd/MM/yyyy').format(latestDataPoint.date);
          _touchedIndex =
              lastIndex; // Set the initial touched index to the last index
        });
      }
    });
  }

  Future<void> _loadCurrencyHistory(String currency, int days) async {
    _currencyHistory =
        await FirestoreService().fetchCurrencyHistory(currency, days);
    final List<double> allValues = _currencyHistory.history
        .expand((data) => [data.sell, data.buy])
        .toList();

    // Set a buffer value that will be used to extend the max and min values by a certain percentage.
    final bufferPercent = 0.02; // 2% buffer
    final maxDataValue = allValues.reduce(math.max);
    final minDataValue = allValues.reduce(math.min);
    final bufferValue = (maxDataValue - minDataValue) * bufferPercent;

    setState(() {
      _isLoading = false;
      _maxYValue = maxDataValue + bufferValue; // Add buffer to the max value
      _minYValue =
          minDataValue - bufferValue; // Subtract buffer from the min value
      _midYValue = (_maxYValue + _minYValue) / 2;
    });
  }

  LineChartData _mainData() {
    return LineChartData(
      gridData: FlGridData(show: false),
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
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                    textAlign: TextAlign.right)
                : Container(),
          ),
        ),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                .map((spot) => LineTooltipItem(
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
              return TouchedSpotIndicatorData(
                FlLine(color: Colors.transparent),
                FlDotData(show: true), // Show the dot
              );
            } else {
              return TouchedSpotIndicatorData(
                FlLine(color: Colors.transparent),
                FlDotData(show: false), // Hide the dot for other indexes
              );
            }
          }).toList();
        },
      ),
      borderData: FlBorderData(show: false),
      maxX: _currencyHistory.history.length.toDouble() - 1,
      maxY: _maxYValue,
      minY: _minYValue,
      lineBarsData: [
        LineChartBarData(
          spots: _currencyHistory.history
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value.buy))
              .toList(),
          isCurved: false,
          barWidth: 5,
          color: Theme.of(context).colorScheme.primary,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
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
              icon: Icon(Icons.refresh),
              onPressed: () {
                // Add your refresh action here
              },
            ),
          ],
        ),
        body: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          '1 $_selectedCurrency = $_selectedValue',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          _selectedDate,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    AspectRatio(
                      aspectRatio: 1.2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: LineChart(_mainData()),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            // Handle 1M option
                            setState(() {
                              _timeSpan = 30;
                            });
                            _loadCurrencyHistory(_selectedCurrency, _timeSpan);
                          },
                          child: Text(
                            '1M',
                            style: TextStyle(
                              color:
                                  _timeSpan == 30 ? Colors.blue : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // Handle 6M option
                            setState(() {
                              _timeSpan = 180;
                            });
                            _loadCurrencyHistory(_selectedCurrency, _timeSpan);
                          },
                          child: Text(
                            '6M',
                            style: TextStyle(
                              color:
                                  _timeSpan == 180 ? Colors.blue : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // Handle 1Y option
                            setState(() {
                              _timeSpan = 365;
                            });
                            _loadCurrencyHistory(_selectedCurrency, _timeSpan);
                          },
                          child: Text(
                            '1Y',
                            style: TextStyle(
                              color:
                                  _timeSpan == 365 ? Colors.blue : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // Handle 2Y option
                            setState(() {
                              _timeSpan = 730;
                            });
                            _loadCurrencyHistory(_selectedCurrency, _timeSpan);
                          },
                          child: Text(
                            '2Y',
                            style: TextStyle(
                              color:
                                  _timeSpan == 730 ? Colors.blue : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      );
}
