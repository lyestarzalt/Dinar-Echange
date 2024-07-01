import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final double verticalPadding;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.verticalPadding = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
          child: Row(
            children: [
              Icon(icon, size: 28.0, color: theme.colorScheme.onSurface),
              const SizedBox(width: 24),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
