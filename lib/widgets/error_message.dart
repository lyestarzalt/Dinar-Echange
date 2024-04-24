import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorMessage({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.onErrorContainer,
          size: 48,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
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
            color: Theme.of(context)
                .colorScheme
                .onErrorContainer, 
            fontSize: 16,
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
                  color: Theme.of(context).colorScheme.onError,
                  fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}
