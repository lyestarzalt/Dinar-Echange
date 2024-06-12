import 'package:flutter/material.dart';
import 'package:dinar_echange/widgets/error_message.dart';

class ErrorApp extends StatelessWidget {

  final VoidCallback onRetry;

  const ErrorApp(
      {super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Error Screen',
      child: Material(
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          body: Center(
            child: ErrorMessage(
              onRetry: onRetry,
            ),
          ),
        ),
      ),
    );
  }
}
