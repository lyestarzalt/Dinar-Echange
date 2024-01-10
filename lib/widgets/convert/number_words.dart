import 'package:flutter/material.dart';
import 'package:dinar_watch/data/models/currency.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dinar_watch/utils/spelling_number.dart';
import 'package:dinar_watch/providers/converter_provider.dart';
import 'package:provider/provider.dart';

class NumberToWordsDisplay extends StatelessWidget {
  final Currency currency;
  final bool isDZDtoCurrency;
  final TextEditingController numberController;

  const NumberToWordsDisplay({
    super.key,
    required this.currency,
    required this.isDZDtoCurrency,
    required this.numberController,
  });

  @override
  Widget build(BuildContext context) {
    String currentLanguageCode = Localizations.localeOf(context).languageCode;

    return Consumer<ConvertProvider>(
      builder: (context, provider, child) {
        String numberInWords = _convertNumberToWords(
          context,
          currentLanguageCode,
          numberController.text,
          provider.useCentimes,
        );

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          constraints: BoxConstraints(
            minHeight: 50,
            maxWidth: MediaQuery.of(context).size.width - 32,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: const BorderRadius.all(Radius.circular(6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  numberInWords,
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              if (isDZDtoCurrency) // Only show if conversion is from DZD
                RotatedBox(
                  quarterTurns: 1,
                  child: Switch(
                    value: provider.useCentimes,
                    onChanged: (value) => provider.toggleUseCentimes(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _convertNumberToWords(
    BuildContext context,
    String languageCode,
    String numberText,
    bool useCentimes,
  ) {
    if (numberText.isEmpty) {
      return AppLocalizations.of(context)!.noNumberEntered;
    }

    double number = double.tryParse(numberText) ?? 0;
    if (useCentimes) {
      number *= 100; // Convert to centimes if the flag is true
    }

    String unit = isDZDtoCurrency
        ? (useCentimes ? 'Centime' : currency.currencyCode.toUpperCase())
        : 'DZD';

    if (languageCode == 'ar') {
      unit = isDZDtoCurrency
          ? (useCentimes ? 'سنتيم' : 'دينار')
          : 'دينار'; // Replace with correct Arabic words
      return "$unit ${SpellingNumber(lang: languageCode).convert(number)}";
    }

    return "${SpellingNumber(lang: languageCode).convert(number)} $unit";
  }
}
