import 'package:flutter/material.dart';
import 'package:dinar_watch/widgets/error_message.dart';

class ErrorApp extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorApp({Key? key, required this.errorMessage, required this.onRetry})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
        child: Scaffold(
          body: ErrorMessage(
            title: 'Error',
            message: errorMessage,
            onRetry: onRetry,
          ),
        ),
      ),
    );
  }
}
