import 'package:flutter/material.dart';
import 'package:dinar_watch/widgets/error_message.dart';

class ErrorApp extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorApp(
      {super.key, required this.errorMessage, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        body: Center(
          child: ErrorMessage(
            title: 'Oops! Something went wrong',
            message: errorMessage,
            onRetry: onRetry,
          ),
        ),
      ),
    );
  }
}
