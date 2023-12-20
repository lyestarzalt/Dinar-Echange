import 'package:flutter/material.dart';

class TimeSpanButtons extends StatelessWidget {
  final Function(int) onTimeSpanSelected;

  const TimeSpanButtons({super.key, required this.onTimeSpanSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTimeSpanButton('1M', 30),
        _buildTimeSpanButton('6M', 180),
        _buildTimeSpanButton('1Y', 365),
        _buildTimeSpanButton('2Y', 730),
      ],
    );
  }

  Widget _buildTimeSpanButton(String label, int days) {
    return InkWell(
      onTap: () => onTimeSpanSelected(days),
      child: Padding(
        padding: const EdgeInsets.all(15.0), // Adjust padding as needed
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
