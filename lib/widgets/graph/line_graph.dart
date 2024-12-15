import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dinar_echange/data/models/currency_history.dart';
import 'package:intl/intl.dart';

class LineGraph extends StatelessWidget {
  final List<CurrencyHistoryEntry> historyEntries;
  final int touchedIndex;
  final double minYValue;
  final double midYValue;
  final double maxYValue;
  final double maxX;
  final Function(int, List<CurrencyHistoryEntry>) onIndexChangeCallback;

  const LineGraph({
    super.key,
    required this.historyEntries,
    required this.touchedIndex,
    required this.minYValue,
    required this.midYValue,
    required this.maxYValue,
    required this.maxX,
    required this.onIndexChangeCallback,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      buildMainData(
        context: context,
        touchedIndex: touchedIndex,
        minYValue: minYValue,
        midYValue: midYValue,
        maxYValue: maxYValue,
        maxX: maxX,
        historyEntries: historyEntries,
        onIndexChangeCallback: onIndexChangeCallback,
      ),
      /*  swapAnimationDuration:
          Duration.zero, // Prevent animation for smoother updates */
    );
  }
}

LineChartData buildMainData({
  required BuildContext context,
  required double minYValue,
  required double midYValue,
  required double maxYValue,
  required int touchedIndex,
  required double maxX,
  required List<CurrencyHistoryEntry> historyEntries,
  required Function(int, List<CurrencyHistoryEntry>) onIndexChangeCallback,
}) {
  // Prevent zero interval
  final interval =
      (maxYValue - minYValue) > 0 ? (maxYValue - minYValue) / 2 : 1.0;

  return LineChartData(
    gridData: FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: interval,
      getDrawingHorizontalLine: (value) {
        if (value == minYValue || value == midYValue || value == maxYValue) {
          return FlLine(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            strokeWidth: 1,
            dashArray: [5],
          );
        }
        return FlLine(strokeWidth: 0);
      },
    ),
    titlesData: buildTitlesData(context, minYValue, midYValue, maxYValue),
    lineTouchData: LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (_) => [],
      ),
      handleBuiltInTouches: true,
      touchCallback: (event, touchResponse) {
        if (event.isInterestedForInteractions &&
            touchResponse?.lineBarSpots != null &&
            touchResponse!.lineBarSpots!.isNotEmpty) {
          final spot = touchResponse.lineBarSpots!.first;
          final newIndex = spot.x.toInt();
          if (newIndex >= 0 && newIndex < historyEntries.length) {
            onIndexChangeCallback(newIndex, historyEntries);
          }
        }
      },
      getTouchLineStart: (_, __) =>
          double.infinity, // Makes vertical line full height
      getTouchedSpotIndicator: (barData, spotIndexes) {
        return spotIndexes.map((spotIndex) {
          return TouchedSpotIndicatorData(
            FlLine(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
            FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: barData.color!,
                strokeWidth: 0,
              ),
            ),
          );
        }).toList();
      },
    ),
    borderData: FlBorderData(show: false),
    maxX: maxX,
    maxY: maxYValue,
    minY: minYValue,
    clipData: FlClipData.all(),
    lineBarsData: buildLineBarsData(context, historyEntries, touchedIndex),
  );
}

List<LineChartBarData> buildLineBarsData(BuildContext context,
    List<CurrencyHistoryEntry> filteredHistoryEntries, int touchedIndex) {
  final firstValue = filteredHistoryEntries.first.buy;
  final lastValue = filteredHistoryEntries.last.buy;
  final isUpTrend = lastValue >= firstValue;
  final lineColor = isUpTrend ? Colors.green : Colors.red;

  if (touchedIndex < 0) {
    return [
      LineChartBarData(
        spots: filteredHistoryEntries
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value.buy))
            .toList(),
        isCurved: false,
        barWidth: 3,
        color: lineColor,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      ),
    ];
  }

  return [
    // Past data (before touched point)
    LineChartBarData(
      spots: filteredHistoryEntries
          .asMap()
          .entries
          .take(touchedIndex + 1)
          .map((e) => FlSpot(e.key.toDouble(), e.value.buy))
          .toList(),
      isCurved: false,
      barWidth: 3,
      color: lineColor,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    ),
    // Future data (after touched point)
    LineChartBarData(
      spots: filteredHistoryEntries
          .asMap()
          .entries
          .skip(touchedIndex)
          .map((e) => FlSpot(e.key.toDouble(), e.value.buy))
          .toList(),
      isCurved: false,
      barWidth: 3,
      color: lineColor.withOpacity(0.3),
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    ),
  ];
}

FlTitlesData buildTitlesData(BuildContext context, double minYValue,
    double midYValue, double maxYValue) {
  return FlTitlesData(
    rightTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 50,
        interval: (maxYValue - minYValue) / 2,
        getTitlesWidget: (value, meta) {
          if (value == minYValue || value == midYValue || value == maxYValue) {
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                value.toInt().toString(),
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    ),
    bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  );
}

LineTouchData buildLineTouchData(
  BuildContext context,
  int touchedIndex,
  List<CurrencyHistoryEntry> historyEntries,
  Function(int, List<CurrencyHistoryEntry>) onIndexChangeCallback,
) {
  return LineTouchData(
    enabled: true,
    touchTooltipData: LineTouchTooltipData(
      getTooltipItems: (_) => [],
    ),
    handleBuiltInTouches: true,
    touchCallback: (event, touchResponse) {
      if (event.isInterestedForInteractions &&
          touchResponse?.lineBarSpots != null) {
        final spot = touchResponse!.lineBarSpots!.first;
        final newIndex = spot.x.toInt();
        if (newIndex != touchedIndex) {
          onIndexChangeCallback(newIndex, historyEntries);
        }
      }
    },
    getTouchedSpotIndicator: (_, spots) {
      return spots.map((spot) {
        return TouchedSpotIndicatorData(
          FlLine(
            color: Colors.transparent, // Hide the default vertical line
          ),
          FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
              radius: 4,
              color: barData.color!,
              strokeWidth: 0,
            ),
          ),
        );
      }).toList();
    },
  );
}
