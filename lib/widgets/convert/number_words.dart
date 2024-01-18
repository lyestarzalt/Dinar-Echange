import 'package:flutter/material.dart';
import 'package:dinar_watch/data/models/currency.dart';
import 'package:dinar_watch/utils/spelling_number.dart';
import 'package:dinar_watch/providers/converter_provider.dart';
import 'package:dinar_watch/utils/extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NumberToWordsDisplay extends StatefulWidget {
  final Currency currency;
  final bool isDZDtoCurrency;
  final TextEditingController numberController;
  final ConvertProvider provider;

  const NumberToWordsDisplay({
    super.key,
    required this.currency,
    required this.isDZDtoCurrency,
    required this.numberController,
    required this.provider,
  });

  @override
  State<NumberToWordsDisplay> createState() => _NumberToWordsDisplayState();
}

class _NumberToWordsDisplayState extends State<NumberToWordsDisplay> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        //constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          AppLocalizations.of(context)!.why_centime_title,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        content: Text(
                            AppLocalizations.of(context)!.centime_explanation),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.info_outline),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isDZDtoCurrency) ...[
                    Text(
                      _convertNumberToWords(
                          Localizations.localeOf(context).languageCode,
                          widget.numberController.text,
                          false,
                          context),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _convertNumberToWords(
                          Localizations.localeOf(context).languageCode,
                          widget.numberController.text,
                          true,
                          context),
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _convertNumberToWords(
    String languageCode,
    String numberText,
    bool useCentimes,
    BuildContext context,
  ) {
    if (numberText.isEmpty || !widget.isDZDtoCurrency) {
      return '';
    }

    double number = double.tryParse(numberText) ?? 0;
    if (useCentimes) {
      number *= 100;
    }

    String unit = useCentimes
        ? AppLocalizations.of(context)!.centime_symbol
        : AppLocalizations.of(context)!.dzd_symbol;

    // the lib does not support chinese so we have to revert to english
    String numberInWords =
        SpellingNumber(lang: languageCode == 'zh' ? 'en' : languageCode)
            .convert(number)
            .capitalizeEveryWord();

    if (languageCode == 'ar') {
      return "$numberInWords $unit";
    }

    return "$numberInWords $unit";
  }
}
