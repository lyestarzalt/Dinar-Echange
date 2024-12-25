import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

class CustomLineGraph extends StatefulWidget {
  final List<double> dataPoints;
  final List<DateTime> dates;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;
  final Color labelColor;
  final double strokeWidth;
  final Function(int index, DateTime date, double value)? onPointSelected;

  const CustomLineGraph({
    Key? key,
    required this.dataPoints,
    required this.dates,
    this.lineColor = Colors.blue,
    this.fillColor = Colors.blue,
    this.gridColor = Colors.grey,
    this.labelColor = Colors.black,
    this.strokeWidth = 2.0,
    this.onPointSelected,
  }) : super(key: key);

  @override
  State<CustomLineGraph> createState() => _CustomLineGraphState();
}

class _CustomLineGraphState extends State<CustomLineGraph> {
  int? selectedIndex;
  Offset? touchPosition;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanUpdate: (details) {
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final position = renderBox.globalToLocal(details.globalPosition);
            _updateSelectedIndex(position, constraints.maxWidth);
          },
          onPanEnd: (_) {
            setState(() {
              selectedIndex = null;
              touchPosition = null;
            });
          },
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _LineGraphPainter(
              dataPoints: widget.dataPoints,
              dates: widget.dates,
              lineColor: widget.lineColor,
              fillColor: widget.fillColor.withOpacity(0.2),
              gridColor: widget.gridColor,
              labelColor: widget.labelColor,
              strokeWidth: widget.strokeWidth,
              selectedIndex: selectedIndex,
              touchPosition: touchPosition,
            ),
          ),
        );
      },
    );
  }

  void _updateSelectedIndex(Offset position, double width) {
    if (widget.dataPoints.isEmpty) return;

    final pointWidth = width / (widget.dataPoints.length - 1);
    final index = (position.dx / pointWidth).round();

    if (index >= 0 && index < widget.dataPoints.length) {
      setState(() {
        selectedIndex = index;
        touchPosition = position;
      });

      widget.onPointSelected?.call(
        index,
        widget.dates[index],
        widget.dataPoints[index],
      );
    }
  }
}

class _LineGraphPainter extends CustomPainter {
  final List<double> dataPoints;
  final List<DateTime> dates;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;
  final Color labelColor;
  final double strokeWidth;
  final int? selectedIndex;
  final Offset? touchPosition;

  _LineGraphPainter({
    required this.dataPoints,
    required this.dates,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
    required this.labelColor,
    required this.strokeWidth,
    this.selectedIndex,
    this.touchPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    _drawGrid(canvas, size);
    _drawLabels(canvas, size);
    _drawLine(canvas, size, paint);
    _drawFill(canvas, size, fillPaint);

    if (selectedIndex != null && touchPosition != null) {
      _drawSelectedPoint(canvas, size);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor.withOpacity(0.3)
      ..strokeWidth = 0.5;

    // Draw horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw vertical grid lines
    for (int i = 0; i <= 6; i++) {
      final x = size.width * (i / 6);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  void _drawLabels(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final maxValue = dataPoints.reduce(math.max);
    final minValue = dataPoints.reduce(math.min);

    // Draw Y-axis labels
    for (int i = 0; i <= 4; i++) {
      final value = minValue + (maxValue - minValue) * (i / 4);
      final textSpan = TextSpan(
        text: value.toStringAsFixed(2),
        style: TextStyle(color: labelColor, fontSize: 10),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(-textPainter.width - 5,
            size.height * (1 - i / 4) - textPainter.height / 2),
      );
    }

    // Draw X-axis labels (dates)
    for (int i = 0; i < dates.length; i += dates.length ~/ 6) {
      final textSpan = TextSpan(
        text: '${dates[i].month}/${dates[i].day}',
        style: TextStyle(color: labelColor, fontSize: 10),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final x = size.width * (i / (dates.length - 1));
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height + 5),
      );
    }
  }

  void _drawLine(Canvas canvas, Size size, Paint paint) {
    if (dataPoints.isEmpty) return;

    final path = Path();
    final maxValue = dataPoints.reduce(math.max);
    final minValue = dataPoints.reduce(math.min);
    final range = maxValue - minValue;

    for (int i = 0; i < dataPoints.length; i++) {
      final x = size.width * (i / (dataPoints.length - 1));
      final normalizedY = (dataPoints[i] - minValue) / range;
      final y = size.height * (1 - normalizedY);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawFill(Canvas canvas, Size size, Paint fillPaint) {
    if (dataPoints.isEmpty) return;

    final path = Path();
    final maxValue = dataPoints.reduce(math.max);
    final minValue = dataPoints.reduce(math.min);
    final range = maxValue - minValue;

    // Start from bottom-left
    path.moveTo(0, size.height);

    // Draw line through all points
    for (int i = 0; i < dataPoints.length; i++) {
      final x = size.width * (i / (dataPoints.length - 1));
      final normalizedY = (dataPoints[i] - minValue) / range;
      final y = size.height * (1 - normalizedY);
      path.lineTo(x, y);
    }

    // Complete the path to create a closed shape
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, fillPaint);
  }

  void _drawSelectedPoint(Canvas canvas, Size size) {
    if (selectedIndex == null || selectedIndex! >= dataPoints.length) return;

    final maxValue = dataPoints.reduce(math.max);
    final minValue = dataPoints.reduce(math.min);
    final range = maxValue - minValue;

    final x = size.width * (selectedIndex! / (dataPoints.length - 1));
    final normalizedY = (dataPoints[selectedIndex!] - minValue) / range;
    final y = size.height * (1 - normalizedY);

    // Draw point
    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), 6, pointPaint);

    // Draw value label
    final value = dataPoints[selectedIndex!];
    final textSpan = TextSpan(
      text: value.toStringAsFixed(2),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    // Draw label background
    final labelPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(x, y - 20),
        width: textPainter.width + 16,
        height: textPainter.height + 8,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(labelRect, labelPaint);

    // Draw label text
    textPainter.paint(
      canvas,
      Offset(
        x - textPainter.width / 2,
        y - 20 - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _LineGraphPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.touchPosition != touchPosition;
  }
}
