import 'package:flutter/material.dart';

class ConversionRateInfo extends StatelessWidget {
  final String conversionRateText;
  final TextStyle textStyle;
  final Color backgroundColor;
  final double minHeight;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  const ConversionRateInfo({
    super.key,
    required this.conversionRateText,
    required this.textStyle,
    this.backgroundColor = Colors.grey,
    this.minHeight = 50.0,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      constraints: BoxConstraints(
        minHeight: minHeight,
        maxWidth: MediaQuery.of(context).size.width - (padding.horizontal),
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Text(
          conversionRateText,
          style: textStyle,
        ),
      ),
    );
  }
}
