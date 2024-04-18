import 'package:flutter/material.dart';
import 'package:dinar_echange/data/models/currency.dart';
import 'package:dinar_echange/utils/spelling_number.dart';
import 'package:dinar_echange/providers/converter_provider.dart';
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
      // why does the Card comes with pridefined padding??
      margin: EdgeInsets.zero,
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Text(
                        AppLocalizations.of(context)!.why_centime_title,
                      ),
                      content: Text(
                        AppLocalizations.of(context)!.centime_explanation,
                      ),
                      actions: <Widget>[
                        TextButton(
                          child:
                              Text(AppLocalizations.of(context)!.close_button),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
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
                  SelectableText(
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
                  SelectableText(
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

    double number = _parseNumber(numberText);
    if (useCentimes) {
      number *= 100;
    }

    String unit = _getUnit(useCentimes, context);
    String languageForConversion = _getLanguageForConversion(languageCode);
    String numberInWords = _numberToWords(languageForConversion, number);

    return _formatResult(languageCode, numberInWords, unit);
  }

  double _parseNumber(String numberText) {
    String cleanNumberText = numberText.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleanNumberText) ?? 0;
  }

  String _getUnit(bool useCentimes, BuildContext context) {
    return useCentimes
        ? AppLocalizations.of(context)!.centime_symbol
        : AppLocalizations.of(context)!.dzd_symbol;
  }

  String _getLanguageForConversion(String languageCode) {
    // The lib does not support Chinese, so revert to English
    return languageCode == 'zh' ? 'en' : languageCode;
  }

  String _numberToWords(String language, double number) {
    return SpellingNumber(lang: language).convert(number).capitalizeEveryWord();
  }

  String _formatResult(String languageCode, String numberInWords, String unit) {
    return "$numberInWords $unit";
  }
  
}

extension CapitalizeExtension on String {
  String capitalizeEveryWord() {
    return split(' ')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }
}
