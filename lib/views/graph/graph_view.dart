import 'package:dinar_watch/providers/graph_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dinar_watch/data/models/currency.dart';
import 'package:dinar_watch/widgets/graph/core_currency_menu.dart';
import 'package:dinar_watch/widgets/graph/time_span_buttons.dart';
import 'package:dinar_watch/widgets/graph/line_graph.dart';
import 'package:animations/animations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dinar_watch/data/models/currency_history.dart';
import 'package:dinar_watch/views/error/error_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dinar_watch/utils/enums.dart';
import 'package:dinar_watch/providers/language_provider.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  final List<Currency> currencies;

  const HistoryPage({super.key, required this.currencies});
  @override
  Widget build(BuildContext context) {
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
        body: Consumer<GraphProvider>(
          builder: (context, provider, _) {
            switch (provider.state.state) {
              case LoadState.loading:
                return const Center(child: LinearProgressIndicator());
              case LoadState.success:
                return _buildCurrencyContent(context, provider);
              case LoadState.error:
                // Use the error message from the provider's state
                return ErrorApp(
                  errorMessage:
                      provider.state.errorMessage ?? 'Error loading data',
                  onRetry: () => provider.fetchCurrencies(currencies),
                );
              default:
                return ErrorApp(
                  errorMessage:
                      provider.state.errorMessage ?? 'Error loading data',
                  onRetry: () => provider.fetchCurrencies(currencies),
                );
            }
          },
        ),
      ),
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
        return SizedBox(
          height: 56.0,
          width: 56.0,
          child: Center(
            child: Icon(
              Icons.menu,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrencyContent(BuildContext context, GraphProvider provider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                child: Column(
                  children: [
                    ValueListenableBuilder<String>(
                      valueListenable: provider.selectedValue,
                      builder: (context, value, child) {
                        return Text(
                          '1 ${provider.selectedCurrency!.currencyCode} = $value',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Consumer<LanguageProvider>(
                      builder: (context, languageProvider, child) {
                        return ValueListenableBuilder<DateTime>(
                          valueListenable: provider.selectedDate,
                          builder: (context, value, child) {
                            // Extract day, month, and year as separate strings
                            String day = DateFormat('d',
                                    languageProvider.currentLocale.toString())
                                .format(value);
                            String month = DateFormat('MMMM',
                                    languageProvider.currentLocale.toString())
                                .format(value);
                            String year = DateFormat('y',
                                    languageProvider.currentLocale.toString())
                                .format(value);

                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 25, // Fixed width for day
                                  child: Text(
                                    day,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 137, // Fixed width for month
                                  child: Text(
                                    month,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    width: 5), // Space between month and year
                                SizedBox(
                                  width: 50, // Fixed width for year
                                  child: Text(
                                    year,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                ),
                              ],
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
            AspectRatio(
              aspectRatio: 1.0,
              child: LineChart(
                buildMainData(
                    context: context,
                    minYValue: provider.minYValue,
                    midYValue: provider.midYValue,
                    maxYValue: provider.maxYValue,
                    touchedIndex: provider.touchedIndex.value,
                    maxX: provider.maxX,
                    historyEntries: provider.filteredHistoryEntries,
                    onIndexChangeCallback:
                        (int index, List<CurrencyHistoryEntry> entries) {
                      provider.updateSelectedData(index);
                    }),
              ),
            ),
            const SizedBox(height: 20),
            TimeSpanButtons(
              onTimeSpanSelected: (days) => provider.processData(days: days),
            ),
          ],
        ),
      ),
    );
  }
}
