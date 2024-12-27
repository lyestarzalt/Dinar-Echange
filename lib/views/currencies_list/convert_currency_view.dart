import 'package:flutter/material.dart';
import 'package:dinar_echange/widgets/convert/currency_input.dart';
import 'package:dinar_echange/widgets/convert/number_words.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:dinar_echange/providers/converter_provider.dart';
import 'package:provider/provider.dart';
import 'package:dinar_echange/widgets/adbanner.dart';
import 'package:dinar_echange/providers/admob_provider.dart';
import 'package:dinar_echange/data/models/currency.dart';

class CurrencyConverterPage extends StatefulWidget {
  final String marketType;

  const CurrencyConverterPage({super.key, required this.marketType});

  @override
  CurrencyConverterPageState createState() => CurrencyConverterPageState();
}

class CurrencyConverterPageState extends State<CurrencyConverterPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ConvertProvider>(context);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CurrencyAppBar(currency: provider.currency),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /*               
                  CurrencyValueCard(
                  currency: provider.currency,
                ), */
                Converter(
                  context: context,
                  provider: provider,
                  marketType: widget.marketType,
                ),
                ChangeNotifierProvider<AdProvider>(
                  create: (_) => AdProvider(),
                  child: Consumer<AdProvider>(
                    builder: (context, adProvider, _) => ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 50),
                      child: const AdBannerWidget(),
                    ),
                  ),
                ),
                Visibility(
                  visible: !provider.isDZDtoCurrency,
                  child: NumberToWordsDisplay(
                    currency: provider.currency,
                    isDZDtoCurrency: !provider.isDZDtoCurrency,
                    numberController: provider.isDZDtoCurrency
                        ? provider.amountController
                        : provider.resultController,
                    provider: provider,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Converter extends StatelessWidget {
  const Converter(
      {super.key,
      required this.context,
      required this.provider,
      required this.marketType});
  final String marketType;
  final BuildContext context;
  final ConvertProvider provider;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ConvertProvider>(context);
    final screenHeight =
        MediaQuery.of(context).size.height - AppBar().preferredSize.height;
    final middlePoint = screenHeight * 0.17;
    final cardHeight = screenHeight / 8;
    const gapBetweenCards = 24.0; // Increased gap between cards
    final topCardTopPosition = middlePoint - cardHeight - (gapBetweenCards / 2);
    final bottomCardTopPosition = middlePoint + (gapBetweenCards / 2);
    const fabSize = 45.0; // Slightly smaller FAB
    final fabTopPosition = middlePoint - (fabSize / 2);

    return SizedBox(
      height: screenHeight / 3,
      child: Stack(
        children: [
          // Top Card - Foreign currency input field
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: provider.isDZDtoCurrency
                ? topCardTopPosition
                : bottomCardTopPosition,
            left: 0,
            right: 0,
            height: cardHeight,
            child: buildCurrencyInput(
                controller: provider.isDZDtoCurrency
                    ? provider.amountController
                    : provider.resultController,
                inputController: provider.amountController,
                currencyCode: 'DZD',
                flag: provider.currency.flag,
                focusNode: provider.isDZDtoCurrency
                    ? provider.amountFocusNode
                    : provider.resultFocusNode,
                context: context),
          ),
          // Bottom Card - Algerian currency field
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: provider.isDZDtoCurrency
                ? bottomCardTopPosition
                : topCardTopPosition,
            left: 0,
            right: 0,
            height: cardHeight,
            child: buildCurrencyInput(
                controller: provider.isDZDtoCurrency
                    ? provider.resultController
                    : provider.amountController,
                inputController: provider.amountController,
                currencyCode: provider.currency.currencyCode,
                flag: provider.currency.flag,
                focusNode: provider.isDZDtoCurrency
                    ? provider.resultFocusNode
                    : provider.amountFocusNode,
                context: context),
          ),
          Positioned(
            top: fabTopPosition,
            right: 8,
            child: Semantics(
              button: true,
              label: AppLocalizations.of(context)!.switch_tooltip,
              child: FloatingActionButton(
                tooltip: AppLocalizations.of(context)!.switch_tooltip,
                onPressed: provider.toggleConversionDirection,
                elevation: 2,
                heroTag:
                    'AddCurrencyFAB${marketType}', // Dynamically setting heroTag using marketType

                child: const Icon(Icons.swap_vert),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CurrencyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Currency currency;

  const CurrencyAppBar({
    super.key,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Container(
        alignment: Alignment.centerLeft, // Align title to the left
        width:
            double.infinity, // Ensure the container takes all available space
        child: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                text: "${currency.currencyName} ",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        _buildRateDisplay(
            context, AppLocalizations.of(context)!.buy, currency.buy),
        _buildRateDisplay(
            context, AppLocalizations.of(context)!.sell, currency.sell),
        const SizedBox(width: 16), // Right padding for the last item
      ],
      elevation: 0,
      centerTitle: true, // Center the title
    );
  }

  Widget _buildRateDisplay(BuildContext context, String label, double rate) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          Text(
            rate.toStringAsFixed(2),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
