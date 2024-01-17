import 'package:flutter/material.dart';
import 'package:dinar_watch/data/models/currency.dart';
import 'package:dinar_watch/utils/spelling_number.dart';
import 'package:dinar_watch/providers/converter_provider.dart';
import 'package:dinar_watch/utils/extenstions.dart';
import 'package:provider/provider.dart';

class NumberToWordsDisplay extends StatefulWidget {
  final Currency currency;
  final bool isDZDtoCurrency;
  final TextEditingController numberController;
  final ConvertProvider provider;

  const NumberToWordsDisplay(
      {super.key,
      required this.currency,
      required this.isDZDtoCurrency,
      required this.numberController,
      required this.provider});

  @override
  State<NumberToWordsDisplay> createState() => _NumberToWordsDisplayState();
}

class _NumberToWordsDisplayState extends State<NumberToWordsDisplay> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConvertProvider>(
      builder: (context, provider, child) {
        return Card(
          child: Container(
            constraints: BoxConstraints(
              minHeight: 50,
              maxWidth: MediaQuery.of(context).size.width - 32,
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Flexible(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        provider
                            .toggleUseCentimes(); // Assuming this toggles between two states only
                      },
                      children: [
                        _buildTextPage(
                          context,
                          provider,
                          useCentimes: false,
                        ),
                        _buildTextPage(
                          context,
                          provider,
                          useCentimes: true,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(2, (index) {
                        // Assuming only two states for useCentimes
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 10,
                          width: 10,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: provider.useCentimes == (index == 1)
                                ? Colors.green
                                : Colors.grey,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextPage(BuildContext context, ConvertProvider provider,
      {required bool useCentimes}) {
    // Determine which controller to use based on the conversion direction
    TextEditingController currentController = provider.amountController;

    String numberInWords = _convertNumberToWords(
      context,
      Localizations.localeOf(context).languageCode,
      currentController.text,
      useCentimes,
    );

    return Text(
      numberInWords,
      style: TextStyle(
        fontSize: 20,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  String _convertNumberToWords(
    BuildContext context,
    String languageCode,
    String numberText,
    bool useCentimes,
  ) {
    if (numberText.isEmpty) {
      return 'Enter';
    }

    double number = double.tryParse(numberText) ?? 0;
    if (useCentimes) {
      number *= 100;
    }

    String unit = widget.isDZDtoCurrency
        ? (useCentimes ? 'Centime' : widget.currency.currencyCode.toUpperCase())
        : 'DZD';

    if (languageCode == 'ar') {
      unit =
          widget.isDZDtoCurrency ? (useCentimes ? 'سنتيم' : 'دينار') : 'دينار';
      return "$unit ${SpellingNumber(lang: languageCode).convert(number).capitalizeEveryWord()}";
    }

    return "${SpellingNumber(lang: languageCode).convert(number).capitalizeEveryWord()} $unit";
  }
}
