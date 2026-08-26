import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:dinar_echange/data/models/currency_model.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:dinar_echange/providers/list_currency_provider.dart';
import 'package:dinar_echange/widgets/flag_container.dart';

/// Pick which currencies to keep in the list. Search field pinned under
/// the AppBar; a persistent scrollable list below; a done button in the
/// AppBar's trailing slot (replaces the previous FloatingActionButton-
/// in-actions anti-pattern).
class AddCurrencyPage extends StatelessWidget {
  const AddCurrencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ListCurrencyProvider>(
      builder: (context, provider, _) {
        final l10n = AppLocalizations.of(context)!;
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(l10n.add_currencies_tooltip),
              actions: [
                IconButton(
                  tooltip: l10n.add_selected_currencies_tooltip,
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    provider.saveSelectedCurrencies();
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 4),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: TextField(
                      controller: provider.searchController,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: l10n.search_hint,
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: provider.filteredCurrencies.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      itemBuilder: (context, index) {
                        final currency = provider.filteredCurrencies[index];
                        final isSelected =
                            provider.selectedCurrencies.contains(currency);
                        return _CurrencyPickRow(
                          currency: currency,
                          isSelected: isSelected,
                          onToggle: () =>
                              provider.addOrRemoveCurrency(currency, !isSelected),
                        );
                      },
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
}

class _CurrencyPickRow extends StatelessWidget {
  final Currency currency;
  final bool isSelected;
  final VoidCallback onToggle;

  const _CurrencyPickRow({
    required this.currency,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            FlagContainer(
              imageUrl: currency.flag,
              width: 36,
              height: 26,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(currency.currencyCode, style: t.textTheme.titleLarge),
                  if (currency.currencyName != null &&
                      currency.currencyName!.isNotEmpty)
                    Text(
                      currency.currencyName!,
                      style: t.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Checkbox.adaptive(
              value: isSelected,
              onChanged: (v) {
                if (v != null) onToggle();
              },
            ),
          ],
        ),
      ),
    );
  }
}
