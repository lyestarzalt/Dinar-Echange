import 'package:flutter/material.dart';
import 'package:dinar_echange/widgets/flag_container.dart';
import 'package:dinar_echange/utils/textfield_format.dart';

Widget buildCurrencyInput({
  required TextEditingController controller,
  required TextEditingController inputController,
  required String currencyCode,
  String? flag,
  required FocusNode focusNode,
  required BuildContext context,
}) {
  bool isInputEnabled = controller == inputController;

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
    margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
    color: Theme.of(context).colorScheme.surface,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (currencyCode == 'DZD')
            Image.asset('assets/dz_flag.png', width: 50, height: 40)
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
              inputFormatters: [InputFormatter()],
              focusNode: focusNode,
              controller: controller,
              decoration: InputDecoration(
                labelText: currencyCode.toUpperCase(),
                labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w300),
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
