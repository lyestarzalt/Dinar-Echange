import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorMessage({
    super.key,
    this.title = 'Oops! Something went wrong.',
    this.message =
        'Unable to load the data. Please check your connection and try again.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 16),
            if (onRetry != null)
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
