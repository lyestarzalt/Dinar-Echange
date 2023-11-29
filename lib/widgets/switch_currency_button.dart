// widgets/switch_currency_button.dart

import 'package:flutter/material.dart';

class SwitchCurrencyButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SwitchCurrencyButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: (MediaQuery.of(context).size.height * 0.15 +
              (MediaQuery.of(context).size.height * 0.3)) /
          2,
      right: 8,
      child: FloatingActionButton(
        onPressed: onPressed,
        child: const Icon(Icons.swap_vert),
        elevation: 2,
      ),
    );
  }
}
