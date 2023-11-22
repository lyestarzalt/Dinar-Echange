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
  ValueNotifier<int?> touchedSpotIndexNotifier = ValueNotifier(null);

  late double maxYValue;
  late double minYValue;
  late double midYValue;
  int touchedIndex = -1;
  late CurrencyHistory currencyHistory;
  bool isLoading = true;
  int timeSpan = 30; // default to 1 month
  String selectedCurrency = 'EUR'; // default currency
  var logger = Logger(
    printer: PrettyPrinter(),
  );

  @override
  void initState() {
    super.initState();
    loadCurrencyHistory(selectedCurrency, timeSpan);
  }

  void loadCurrencyHistory(String currency, int days) async {
    currencyHistory =
        await FirestoreService().fetchCurrencyHistory(currency, days);

    double overallMaxY =
        currencyHistory.history.map((e) => e.sell).reduce(math.max);
    double overallMinY =
        currencyHistory.history.map((e) => e.buy).reduce(math.min);
    double overallMidY = (overallMaxY + overallMinY) / 2;

    setState(() {
      isLoading = false;
      maxYValue = overallMaxY;
      minYValue = overallMinY;
      midYValue = overallMidY;
    });
  }

  List<FlSpot> getSpots() {
    return currencyHistory.history
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.buy))
        .toList();
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            getTitlesWidget: (value, meta) {
              if (value == minYValue ||
                  value == midYValue ||
                  value == maxYValue) {
                return Text(
                  value.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.right,
                );
              }
              return Container();
            },
            interval: 1,
          ),
        ),
        bottomTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      extraLinesData: ExtraLinesData(
        verticalLines: touchedIndex != -1
            ? [
                VerticalLine(
                  x: touchedIndex.toDouble(),
                  color: Colors.black, // The color of the line
                  strokeWidth: 2, // The thickness of the line
                  // No dash array needed as the line should be solid
                ),
              ]
            : [],
        horizontalLines: [
          HorizontalLine(
            y: minYValue,
            color: Colors.grey,
            strokeWidth: 1,
            dashArray: [5],
          ),
          HorizontalLine(
            y: midYValue,
            color: Colors.grey,
            strokeWidth: 1,
            dashArray: [5],
          ),
          HorizontalLine(
            y: maxYValue,
            color: Colors.grey,
            strokeWidth: 1,
            dashArray: [5],
          ),
        ],
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return []; // Returning an empty list to not show the tooltip
          },
          fitInsideVertically: true,
          fitInsideHorizontally: true,
        ),
        getTouchedSpotIndicator:
            (LineChartBarData barData, List<int> indicators) {
          // Return an empty list to not show the default touched spot indicator line
          return indicators.map((index) {
            return const TouchedSpotIndicatorData(
              FlLine(color: Colors.transparent),
              FlDotData(show: false),
            );
          }).toList();
        },
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          // Ensure that we have a touch response and the event is of interest
          if (!event.isInterestedForInteractions ||
              touchResponse == null ||
              touchResponse.lineBarSpots == null) {
            if (touchedIndex != -1) {
              // Only update the state if it's necessary
              setState(() {
                touchedIndex = -1; // Reset touched index when not interacting
              });
            }
            return;
          }

          final spot = touchResponse.lineBarSpots!.first;
          if (spot != null) {
            int newIndex = spot.x.toInt();
            if (newIndex != touchedIndex) {
              // Only update if the index has changed
              setState(() {
                selectedValue = '${spot.y.toStringAsFixed(2)} DZD';
                selectedDate = DateFormat('dd/MM/yyyy')
                    .format(currencyHistory.history[newIndex].date);
                touchedIndex =
                    newIndex; // Update the touched index to show the vertical line
              });
            }
          }
        },
        handleBuiltInTouches: true,
      ),
      borderData: FlBorderData(show: false),
      maxX: currencyHistory.history.length.toDouble() - 1,
      maxY: maxYValue,
      minY: minYValue,
      lineBarsData: [
        LineChartBarData(
          spots: getSpots(),
          isCurved: true,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );
  }

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    return Text(
      value.toStringAsFixed(2),
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      textAlign: TextAlign.right,
    );
  }

  String selectedValue = ''; // Holds the selected spot's value
  String selectedDate = ''; // Holds the selected spot's date

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency History'),
      ),
      body: Center(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (selectedValue.isNotEmpty && selectedDate.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('$selectedValue\n$selectedDate'),
                    ),
                  AspectRatio(
                    aspectRatio: 1.2,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          right: 18, left: 12, top: 24, bottom: 12),
                      child: LineChart(mainData()),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
