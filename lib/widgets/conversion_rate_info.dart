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
    this.backgroundColor = Colors.grey, // Default color
    this.minHeight = 50.0, // Default minimum height
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      constraints: BoxConstraints(
        minHeight: minHeight,
        maxWidth: MediaQuery.of(context).size.width - (padding.horizontal * 2),
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
