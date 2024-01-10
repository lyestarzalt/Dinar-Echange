import 'package:flutter/material.dart';
import 'package:dinar_watch/widgets/flag_container.dart';


Widget buildCurrencyInput(
    TextEditingController controller,
    TextEditingController inputControl,
    String currencyCode,
    String? flag,
    FocusNode focusNode,
    BuildContext context) {
  bool isInputEnabled = controller == inputControl;

  return Card(
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
      side: BorderSide(
        color: focusNode.hasFocus
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.3),
        width: focusNode.hasFocus ? 3.0 : 0.5,
      ),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
    color: Theme.of(context).colorScheme.background,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (currencyCode == 'DZD')
            Image.asset('assets/dz.png', width: 50, height: 40)
          else if (flag!.isNotEmpty)
            FlagContainer(
              imageUrl: flag,
              width: 50,
              height: 40,
              borderRadius: BorderRadius.circular(1),
            ),
          const SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              focusNode: focusNode,
              controller: controller,
              decoration:
                InputDecoration(
                labelText: currencyCode.toUpperCase(),
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16, // Set your desired font size for input text
                ),
                // Define the style for the label text
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
              ),
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 0.0),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              enabled: isInputEnabled,
            ),
          ),
        ],
      ),
    ),
  );
}
