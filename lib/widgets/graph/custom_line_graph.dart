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
                  lineColor: widget.lineColor,
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
        text: value.toStringAsFixed(3),
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

    // Draw animated path up to the current animation point
    for (int i = 0; i < pointsToShow; i++) {
      final x = size.width * (i / (dataPoints.length - 1));
      final y = _getYPosition(dataPoints[i], size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      if (i == splitIndex) {
        canvas.drawPath(path, leftPaint);
        path.reset();
        path.moveTo(x, y);
      }
    }

    // Draw remaining path with reduced opacity if needed
    if (path.computeMetrics().isNotEmpty) {
      canvas.drawPath(
          path, splitIndex == pointsToShow - 1 ? leftPaint : rightPaint);
    }
  }

  void _drawVerticalLine(Canvas canvas, Size size) {
    if (selectedIndex == null) return;

    final x = size.width * (selectedIndex! / (dataPoints.length - 1));

    final paint = Paint()
      ..color = lineColor.withOpacity(0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    double dashHeight = 5;
    double gapHeight = 3;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, math.min(startY + dashHeight, size.height)),
        paint,
      );
      startY += dashHeight + gapHeight;
    }
  }

  void _drawSelectedPoint(Canvas canvas, Size size) {
    if (selectedIndex == null || selectedIndex! >= dataPoints.length) return;

    final x = size.width * (selectedIndex! / (dataPoints.length - 1));
    final y = _getYPosition(dataPoints[selectedIndex!], size.height);
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
    return height * (1 - ((value - minValue) / (maxValue - minValue)));
  }

  @override
  bool shouldRepaint(covariant _LineGraphPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.touchPosition != touchPosition ||
        oldDelegate.animationValue != animationValue;
  }
}
