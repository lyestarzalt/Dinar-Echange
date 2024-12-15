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
    margin: EdgeInsets.zero,
    color: Theme.of(context).colorScheme.surface,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 40,
            child: currencyCode == 'DZD'
                ? Image.asset('assets/dz_flag.png', fit: BoxFit.contain)
                : flag!.isNotEmpty
                    ? FlagContainer(
                        imageUrl: flag,
                        width: 50,
                        height: 40,
                        borderRadius: BorderRadius.circular(1),
                      )
                    : null,
          ),
          const SizedBox(width: 12.0),

          Expanded(
            child: TextField(
              inputFormatters: InputFormatter.getFormatters(),
              focusNode: focusNode,
              controller: controller,
              decoration: InputDecoration(
                labelText: currencyCode.toUpperCase(),
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.right,
              enabled: isInputEnabled,
              textInputAction: TextInputAction.done,
            ),
          ),
        ],
      ),
    ),
  );
}
