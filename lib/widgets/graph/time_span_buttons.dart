import 'package:flutter/material.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';

class TimeSpanButtons extends StatelessWidget {
  final Function(int) onTimeSpanSelected;

  const TimeSpanButtons({super.key, required this.onTimeSpanSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTimeSpanButton(
            AppLocalizations.of(context)!.one_month_button, 30),
        _buildTimeSpanButton(
            AppLocalizations.of(context)!.six_months_button, 180),
        _buildTimeSpanButton(
            AppLocalizations.of(context)!.one_year_button, 365),
        _buildTimeSpanButton(
            AppLocalizations.of(context)!.two_years_button, 730),
      ],
    );
  }

  Widget _buildTimeSpanButton(String label, int days) {
    return InkWell(
      onTap: () => onTimeSpanSelected(days),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
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
