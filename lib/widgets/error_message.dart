import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';

class ErrorMessage extends StatelessWidget {
  final VoidCallback? onRetry;

  const ErrorMessage({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        container: true,
        label: AppLocalizations.of(context)!.error_message,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.onErrorContainer,
              size: 50,
            ),
            const SizedBox(height: 15),
            Text(
              AppLocalizations.of(context)!.error_title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.error_message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            if (onRetry != null)
              Semantics(
                button: true,
                enabled: true,
                label: AppLocalizations.of(context)!.retry,
                hint: 'Double tap to retry',
                onTap: () {
                  HapticFeedback.mediumImpact();
                  if (onRetry != null) onRetry!();
                },
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    if (onRetry != null) onRetry!();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.retry,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onError,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
