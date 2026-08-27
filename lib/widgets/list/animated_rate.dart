import 'package:flutter/material.dart';

/// Displays a numeric rate that:
///  - counts smoothly from its previous value to the new one when the
///    value changes (Robinhood/Wise-style ticker feel),
///  - briefly flashes green (up) or red (down) during that transition,
///  - stops both effects when the user has "Reduce Motion" enabled.
class AnimatedRate extends StatefulWidget {
  final double value;
  final String Function(double) format;
  final TextStyle style;
  final Color baseColor;
  final Color upColor;
  final Color downColor;
  final TextAlign textAlign;

  const AnimatedRate({
    super.key,
    required this.value,
    required this.format,
    required this.style,
    required this.baseColor,
    required this.upColor,
    required this.downColor,
    this.textAlign = TextAlign.right,
  });

  @override
  State<AnimatedRate> createState() => _AnimatedRateState();
}

class _AnimatedRateState extends State<AnimatedRate>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 900);

  late double _from;
  late double _to;
  late AnimationController _controller;
  Color? _flashTarget;

  @override
  void initState() {
    super.initState();
    _from = widget.value;
    _to = widget.value;
    _controller = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _flashTarget = null);
        }
      });
  }

  @override
  void didUpdateWidget(covariant AnimatedRate old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) {
      final wentUp = widget.value > _to;
      _from = _to;
      _to = widget.value;
      _flashTarget = wentUp ? widget.upColor : widget.downColor;
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (reducedMotion) {
      return Text(
        widget.format(widget.value),
        textAlign: widget.textAlign,
        style: widget.style.copyWith(color: widget.baseColor),
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value; // 0 -> 1
        final currentValue = _from + (_to - _from) * Curves.easeOutCubic.transform(t);
        final color = _flashTarget == null
            ? widget.baseColor
            : Color.lerp(_flashTarget, widget.baseColor, t) ?? widget.baseColor;
        return Text(
          widget.format(currentValue),
          textAlign: widget.textAlign,
          style: widget.style.copyWith(color: color),
        );
      },
    );
  }
}
