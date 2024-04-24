import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:dinar_echange/data/models/currency_history.dart';
import 'package:intl/intl.dart';

List<LineChartBarData> buildLineBarsData(
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

LineTouchData buildLineTouchData(
  BuildContext context,
  int touchedIndex,
  List<CurrencyHistoryEntry> historyEntries,
  Function(int, List<CurrencyHistoryEntry>) onIndexChangeCallback,


) {
  return LineTouchData(
    touchCallback: (event, touchResponse) {
      if (event.isInterestedForInteractions &&
          touchResponse?.lineBarSpots != null) {
        final spot = touchResponse!.lineBarSpots!.first;
        final newIndex = spot.x.toInt();
        if (newIndex != touchedIndex) {
          onIndexChangeCallback(
              newIndex, historyEntries); 
        }
      }
    },
    handleBuiltInTouches: true,
    touchTooltipData: LineTouchTooltipData(
     
      getTooltipColor: (LineBarSpot lineBarSpot) {
        return Colors.transparent;
      },
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
    getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
      return spotIndexes.map((index) {
        return TouchedSpotIndicatorData(
          const FlLine(color: Colors.transparent),
          FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 6,
                color:
                    Theme.of(context).colorScheme.secondary,
                strokeColor: Colors.transparent,
              );
            },
          ),
        );
      }).toList();
    },
  );
}

FlTitlesData buildTitlesData(BuildContext context, double minYValue,
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
  return LineChartData(
    gridData: const FlGridData(show: false),
    titlesData: buildTitlesData(context, minYValue, midYValue, maxYValue),
    extraLinesData: ExtraLinesData(
      horizontalLines: [minYValue, midYValue.round().toDouble(), maxYValue]
          .map((yValue) => HorizontalLine(
              y: yValue,
              color:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
              strokeWidth: 1,
              dashArray: [5]))
          .toList(),
    ),
    lineTouchData: buildLineTouchData(
        context, touchedIndex, historyEntries, onIndexChangeCallback),
    borderData: FlBorderData(show: false),
    maxX: maxX,
    maxY: maxYValue,
    minY: minYValue,
    lineBarsData: buildLineBarsData(context, historyEntries),
  );
}

class IndexChangeResult {
  final int touchedIndex;
  final String selectedValue;
  final String selectedDate;

  IndexChangeResult(
      {required this.touchedIndex,
      required this.selectedValue,
      required this.selectedDate});
}

IndexChangeResult onIndexChange(
    int newIndex, List<CurrencyHistoryEntry> historyEntries) {
  if (newIndex >= 0 && newIndex < historyEntries.length) {
    return IndexChangeResult(
      touchedIndex: newIndex,
      selectedValue: '${historyEntries[newIndex].buy.toStringAsFixed(2)} DZD',
      selectedDate:
          DateFormat('dd/MM/yyyy').format(historyEntries[newIndex].date),
    );
  } else {
    return IndexChangeResult(
        touchedIndex: -1, selectedValue: '', selectedDate: '');
  }
}
