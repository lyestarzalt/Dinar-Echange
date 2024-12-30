import 'package:flutter/material.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:dinar_echange/providers/graph_provider.dart';

class TimeSpanButtons extends StatelessWidget {
  final Function(int) onTimeSpanSelected;

  const TimeSpanButtons({super.key, required this.onTimeSpanSelected});

  @override
  Widget build(BuildContext context) {
    return Consumer<GraphProvider>(
      builder: (context, provider, _) => Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTimeSpanButton(
              AppLocalizations.of(context)!.one_month_button,
              30,
              context,
              provider.displayPeriodDays == 30,
            ),
            _buildTimeSpanButton(
              AppLocalizations.of(context)!.six_months_button,
              180,
              context,
              provider.displayPeriodDays == 180,
            ),
            _buildTimeSpanButton(
              AppLocalizations.of(context)!.one_year_button,
              365,
              context,
              provider.displayPeriodDays == 365,
            ),
            _buildTimeSpanButton(
              AppLocalizations.of(context)!.two_years_button,
              730,
              context,
              provider.displayPeriodDays == 730,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSpanButton(
      String label, int days, BuildContext context, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTimeSpanSelected(days),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }
}
