import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dinar_watch/data/models/currency.dart';
import 'package:dinar_watch/widgets/history/currency_menu.dart';
import 'package:dinar_watch/widgets/history/time_span_buttons.dart';
import 'package:dinar_watch/widgets/error_message.dart';
import 'package:dinar_watch/widgets/history/line_graph.dart';
import 'package:dinar_watch/providers/history_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:animations/animations.dart';
import 'package:dinar_watch/theme/theme_manager.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:dinar_watch/data/models/currency_history.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CurrencyHistoryProvider>(
      create: (_) => CurrencyHistoryProvider(),
      child: Consumer<CurrencyHistoryProvider>(
        builder: (context, provider, _) {
          if (provider.coreCurrencies.isEmpty) {
            // You can show a loading indicator until the currencies are fetched
            return Center(child: CircularProgressIndicator());
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.currency_trends),
            ),
            floatingActionButton: _buildFloatingActionButton(context, provider),
            body: _buildCurrencyContent(context, provider),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton(
      BuildContext context, CurrencyHistoryProvider provider) {
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
      closedColor: Theme.of(context).colorScheme.secondary,
      closedBuilder: (BuildContext context, VoidCallback openContainer) {
        return SizedBox(
          height: 56.0,
          width: 56.0,
          child: Center(
            child: Icon(
              Icons.menu,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrencyContent(
      BuildContext context, CurrencyHistoryProvider provider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '1 ${provider.selectedCurrency!.currencyCode} = ${provider.selectedValue}',
                style: ThemeManager.moneyNumberStyle(context),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                provider.selectedDate,
                style: ThemeManager.currencyCodeStyle(context),
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
                  touchedIndex: provider.touchedIndex,
                  maxX: provider.maxX,
                  historyEntries: provider.filteredHistoryEntries,
                  onIndexChangeCallback:
                      (int index, List<CurrencyHistoryEntry> entries) {
                    provider.touchedIndex = index;
                    provider.selectedValue =
                        '${entries[index].buy.toStringAsFixed(2)} DZD';
                    provider.selectedDate =
                        DateFormat('dd/MM/yyyy').format(entries[index].date);
                  },
                ),
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
