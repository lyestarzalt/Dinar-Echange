import 'package:flutter/material.dart';

/// Text widget for a currency rate that briefly flashes green (up) or red
/// (down) when the value changes, then fades back to [baseColor]. Signals
/// that data is live.
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
  late double _previous;
  late AnimationController _controller;
  Color? _flashTarget;

  @override
  void initState() {
    super.initState();
    _previous = widget.value;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _flashTarget = null);
        }
      });
  }

  @override
  void didUpdateWidget(covariant AnimatedRate old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) {
      final wentUp = widget.value > _previous;
      _previous = widget.value;
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value; // 0 -> 1 over the flash duration
        final color = _flashTarget == null
            ? widget.baseColor
            : Color.lerp(_flashTarget, widget.baseColor, t) ?? widget.baseColor;
        return Text(
          widget.format(widget.value),
          textAlign: widget.textAlign,
          style: widget.style.copyWith(color: color),
        );
      },
    );
  }
}
