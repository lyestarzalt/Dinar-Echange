import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomLineGraph extends StatefulWidget {
  final List<double> dataPoints;
  final List<DateTime> dates;
  final Color lineColor;
  final Color gridColor;
  final Color labelColor;
  final double strokeWidth;
  final bool showBottomLabels;
  final double maxValue;
  final double minValue;
  final double midValue;
  final Function(int index, DateTime date, double value)? onPointSelected;
  final Color upTrendColor;
  final Color downTrendColor;
  const CustomLineGraph({
    Key? key,
    required this.dataPoints,
    required this.dates,
    this.lineColor = Colors.blue,
    this.gridColor = Colors.grey,
    this.labelColor = Colors.black,
    this.strokeWidth = 4.0,
    this.showBottomLabels = false,
    required this.maxValue,
    required this.minValue,
    required this.midValue,
    this.onPointSelected,
    this.upTrendColor = Colors.green,
    this.downTrendColor = Colors.red,
  }) : super(key: key);

  @override
  State<CustomLineGraph> createState() => _CustomLineGraphState();
}

class _CustomLineGraphState extends State<CustomLineGraph>
    with SingleTickerProviderStateMixin {
  int? selectedIndex;
  Offset? touchPosition;
  late AnimationController _animationController;
  late Animation<double> _animation;
  Color get _trendColor {
    if (widget.dataPoints.isEmpty) return widget.upTrendColor;

    final firstValue = widget.dataPoints.first;
    final lastValue = widget.dataPoints.last;

    return lastValue >= firstValue
        ? widget.upTrendColor
        : widget.downTrendColor;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(CustomLineGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dataPoints != widget.dataPoints) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _LineGraphPainter(
                  dataPoints: widget.dataPoints,
                  dates: widget.dates,
                  lineColor: _trendColor, // Use trend color
                  gridColor: widget.gridColor,
                  labelColor: widget.labelColor,
                  strokeWidth: widget.strokeWidth,
                  showBottomLabels: widget.showBottomLabels,
                  maxValue: widget.maxValue,
                  minValue: widget.minValue,
                  midValue: widget.midValue,
                  selectedIndex: selectedIndex,
                  touchPosition: touchPosition,
                  animationValue: _animation.value,
                ),
              );
            },
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
  final Color gridColor;
  final Color labelColor;
  final double strokeWidth;
  final bool showBottomLabels;
  final double maxValue;
  final double minValue;
  final double midValue;
  final int? selectedIndex;
  final Offset? touchPosition;
  final double animationValue;

  _LineGraphPainter({
    required this.dataPoints,
    required this.dates,
    required this.lineColor,
    required this.gridColor,
    required this.labelColor,
    required this.strokeWidth,
    required this.showBottomLabels,
    required this.maxValue,
    required this.minValue,
    required this.midValue,
    required this.animationValue,
    this.selectedIndex,
    this.touchPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawReferenceLines(canvas, size);
    if (showBottomLabels) {
      _drawBottomLabels(canvas, size);
    }
    _drawAnimatedLine(canvas, size);
    if (selectedIndex != null && touchPosition != null) {
      _drawVerticalLine(canvas, size);
      _drawSelectedPoint(canvas, size);
    }
  }

  void _drawReferenceLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor.withOpacity(0.2)
      ..strokeWidth = 1.0;

    final values = [maxValue, midValue, minValue];
    for (var value in values) {
      final y = _getYPosition(value, size.height);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );

      final textSpan = TextSpan(
        text: value.toStringAsFixed(1),
        style: TextStyle(color: labelColor, fontSize: 12),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(size.width + 5, y - textPainter.height / 2),
      );
    }
  }

  void _drawAnimatedLine(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;
    if (size.width <= 0 || size.height <= 0) return;

    final leftPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rightPaint = Paint()
      ..color = lineColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    final pointsToShow = (dataPoints.length * animationValue).ceil();
    final splitIndex = selectedIndex ?? pointsToShow - 1;

    if (pointsToShow <= 0) return;

    try {
      for (int i = 0; i < pointsToShow; i++) {
        if (i >= dataPoints.length) break;

        final xRatio = i / (dataPoints.length - 1);
        if (xRatio.isNaN) continue;

        final x = size.width * xRatio;
        final y = _getYPosition(dataPoints[i], size.height);

        if (x.isNaN || y.isNaN) continue;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }

        if (i == splitIndex) {
          if (path.computeMetrics().isNotEmpty) {
            canvas.drawPath(path, leftPaint);
          }
          path.reset();
          path.moveTo(x, y);
        }
      }

      // Draw remaining path with reduced opacity if needed
      if (path.computeMetrics().isNotEmpty) {
        canvas.drawPath(
            path, splitIndex == pointsToShow - 1 ? leftPaint : rightPaint);
      }
    } catch (e) {
      // Handle any potential errors during drawing
      print('Error drawing line: $e');
    }
  }

  void _drawVerticalLine(Canvas canvas, Size size) {
    if (selectedIndex == null) return;
    if (selectedIndex! >= dataPoints.length) return;
    if (dataPoints.isEmpty) return;

    final xRatio = selectedIndex! / (dataPoints.length - 1);
    if (xRatio.isNaN) return;

    final x = size.width * xRatio;
    if (x.isNaN) return;

    final paint = Paint()
      ..color = lineColor.withOpacity(0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    double dashHeight = 5;
    double gapHeight = 3;
    double startY = 0;

    while (startY < size.height) {
      final endY = math.min(startY + dashHeight, size.height);
      if (!startY.isNaN && !endY.isNaN) {
        canvas.drawLine(
          Offset(x, startY),
          Offset(x, endY),
          paint,
        );
      }
      startY += dashHeight + gapHeight;
    }
  }

  void _drawSelectedPoint(Canvas canvas, Size size) {
    if (selectedIndex == null || selectedIndex! >= dataPoints.length) return;
    if (dataPoints.isEmpty) return;

    final xRatio = selectedIndex! / (dataPoints.length - 1);
    if (xRatio.isNaN) return;

    final x = size.width * xRatio;
    final y = _getYPosition(dataPoints[selectedIndex!], size.height);

    // Skip drawing if we have invalid coordinates
    if (x.isNaN || y.isNaN) return;

    final center = Offset(x, y);

    // Draw white border
    final outerCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, outerCirclePaint);

    // Draw colored inner circle
    final innerCirclePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5, innerCirclePaint);
  }

  void _drawBottomLabels(Canvas canvas, Size size) {
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

  double _getYPosition(double value, double height) {
    // Handle edge cases where values might cause NaN
    if (maxValue == minValue) return height / 2;
    if (value.isNaN || maxValue.isNaN || minValue.isNaN) return 0;

    final normalizedValue = (value - minValue) / (maxValue - minValue);
    if (normalizedValue.isNaN) return 0;

    return height * (1 - normalizedValue);
  }

  @override
  bool shouldRepaint(covariant _LineGraphPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.touchPosition != touchPosition ||
        oldDelegate.animationValue != animationValue;
  }
}
