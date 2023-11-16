import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/currency_history.dart';
import '../services/firebase_service.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:logger/logger.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late CurrencyHistory currencyHistory;
  bool isLoading = true;
  int timeSpan = 90; // default to 1 month
  String selectedCurrency = 'EUR'; // default currency
  var logger = Logger(
    printer: PrettyPrinter(),
  );
  List<Color> gradientColors = [
    Colors.cyan, // Replace with your color
    Colors.blue, // Replace with your color
  ];

  @override
  void initState() {
    super.initState();
    loadCurrencyHistory(selectedCurrency, timeSpan);
  }

  void loadCurrencyHistory(String currency, int days) async {
    currencyHistory =
        await FirestoreService().fetchCurrencyHistory(currency, days);

    for (var item in currencyHistory.history) {
      logger.i(item.buy);
    }

    setState(() {
      isLoading = false;
    });
  }

  List<FlSpot> getSpots() {
    // Example spots generation based on your currency history
    return currencyHistory.history
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.buy))
        .toList();
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
    int totalSpots = currencyHistory.history.length;
    int interval = (totalSpots / 5).ceil(); // Adjust for 5 labels

    if (value.toInt() % interval != 0 || value.toInt() >= totalSpots) {
      return const Text('');
    }

    DateTime date = currencyHistory.history[value.toInt()].date;
    return Text(DateFormat('MMM').format(date), style: style);
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 15);
    return Text('${value.toInt()}', style: style);
  }

  LineChartData mainData() {
    double maxYValue =
        currencyHistory.history.map((e) => e.sell).reduce(math.max);
    double minYValue =
        currencyHistory.history.map((e) => e.buy).reduce(math.min);
    return LineChartData(
      gridData: FlGridData(
        show: false,
        drawVerticalLine: false,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.5),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.5),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
      ),
      minX: 0,
      maxX: currencyHistory.history.length.toDouble() - 1,
      minY: minYValue, // Adjusted to reflect actual min value
      maxY: maxYValue, // Adjusted to reflect actual max value
      lineBarsData: [
        LineChartBarData(
          spots: getSpots(),
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency History'),
        // Placeholder for currency selection dropdown
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                AspectRatio(
                  aspectRatio: 1.2,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 18,
                      left: 12,
                      top: 24,
                      bottom: 12,
                    ),
                    child: LineChart(mainData()),
                  ),
                ),
              ],
            ),
    );
  }
}
