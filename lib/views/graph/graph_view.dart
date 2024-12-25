import 'package:dinar_echange/providers/graph_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dinar_echange/data/models/currency.dart';
import 'package:dinar_echange/widgets/graph/core_currency_menu.dart';
import 'package:dinar_echange/widgets/graph/time_span_buttons.dart';
import 'package:dinar_echange/widgets/graph/custom_line_graph.dart';
import 'package:animations/animations.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:dinar_echange/utils/enums.dart';
import 'package:dinar_echange/providers/app_provider.dart';
import 'package:intl/intl.dart';
import 'package:dinar_echange/widgets/flag_container.dart';
import 'package:dinar_echange/widgets/adbanner.dart';
import 'package:dinar_echange/widgets/error_message.dart';
import 'package:dinar_echange/providers/admob_provider.dart';
import 'package:dinar_echange/providers/appinit_provider.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppInitializationProvider>(
      builder: (context, initProvider, _) {
        List<Currency> currencies = initProvider.currencies!;
        return ChangeNotifierProvider<GraphProvider>(
          create: (_) => GraphProvider(currencies),
          child: Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.trends_app_bar_title),
            ),
            floatingActionButton: Consumer<GraphProvider>(
              builder: (context, provider, _) =>
                  _buildFloatingActionButton(context, provider),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Consumer<GraphProvider>(
                builder: (context, provider, _) {
                  switch (provider.state.state) {
                    case LoadState.loading:
                      return const Center(child: LinearProgressIndicator());
                    case LoadState.success:
                      return _buildCurrencyContent(context, provider);
                    case LoadState.error:
                      return ErrorMessage(
                        onRetry: () => provider.fetchCurrencies(currencies),
                      );
                    default:
                      return ErrorMessage(
                        onRetry: () => provider.fetchCurrencies(currencies),
                      );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton(
      BuildContext context, GraphProvider provider) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fade,
      openBuilder: (BuildContext context, VoidCallback _) {
        return CurrencyMenu(
          coreCurrencies: provider.coreCurrencies,
          onCurrencySelected: (Currency selectedCurrency) {
            provider.selectedCurrency = selectedCurrency;
            provider.loadCurrencyHistory();
          },
          parentContext: context,
        );
      },
      closedElevation: 6.0,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      closedColor: Theme.of(context).colorScheme.primaryContainer,
      closedBuilder: (BuildContext context, VoidCallback openContainer) {
        return Semantics(
          button: true,
          label: AppLocalizations.of(context)!.select_currency_app_bar_title,
          child: SizedBox(
            height: 56.0,
            width: 56.0,
            child: Center(
              child: Icon(
                Icons.menu,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrencyContent(BuildContext context, GraphProvider provider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ChangeNotifierProvider<AdProvider>(
            create: (_) => AdProvider(),
            child: Consumer<AdProvider>(
              builder: (context, adProvider, _) => ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 100),
                child: const AdBannerWidget(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FlagContainer(
                        imageUrl: provider.selectedCurrency!.flag,
                        height: 50,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        provider.selectedCurrency!.currencyCode.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        size: 24,
                      ),
                      const SizedBox(width: 5),
                      const FlagContainer(
                        imageUrl: 'DZD',
                        height: 50,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ValueListenableBuilder<String>(
                    valueListenable: provider.selectedValue,
                    builder: (context, value, child) {
                      return Text(
                        '1 ${provider.selectedCurrency!.currencyCode} = $value',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 1),
                  Consumer<AppProvider>(
                    builder: (context, languageProvider, child) {
                      return ValueListenableBuilder<DateTime>(
                        valueListenable: provider.selectedDate,
                        builder: (context, value, child) {
                          String date = DateFormat(
                            'd MMMM y',
                            languageProvider.currentLocale.toString(),
                          ).format(value);

                          return Text(
                            date,
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(right: 50.0), // padding for labels
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: CustomLineGraph(
                  dataPoints: provider.filteredHistoryEntries
                      .map((entry) => entry.buy)
                      .toList(),
                  dates: provider.filteredHistoryEntries
                      .map((entry) => entry.date)
                      .toList(),
                  gridColor: Theme.of(context).colorScheme.outline,
                  labelColor: Theme.of(context).colorScheme.onSurface,
                  upTrendColor: Colors.green, // Customize trend colors
                  downTrendColor: Colors.red, // Customize trend colors
                  showBottomLabels: false,
                  maxValue: provider.maxYValue,
                  minValue: provider.minYValue,
                  midValue: provider.midYValue,
                  onPointSelected: (index, date, value) {
                    provider.updateSelectedData(index);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TimeSpanButtons(
            onTimeSpanSelected: (days) => provider.setTimeSpan(days),
          ),
        ],
      ),
    );
  }
}
