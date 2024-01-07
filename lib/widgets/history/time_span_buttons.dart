import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TimeSpanButtons extends StatelessWidget {
  final Function(int) onTimeSpanSelected;

  const TimeSpanButtons({super.key, required this.onTimeSpanSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTimeSpanButton(AppLocalizations.of(context)!.one_month, 30),
        _buildTimeSpanButton(AppLocalizations.of(context)!.six_months, 180),
        _buildTimeSpanButton(AppLocalizations.of(context)!.one_year, 365),
        _buildTimeSpanButton(AppLocalizations.of(context)!.two_years, 730),
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
