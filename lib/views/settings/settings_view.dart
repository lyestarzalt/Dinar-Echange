import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';

import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:dinar_echange/providers/admob_provider.dart';
import 'package:dinar_echange/providers/app_provider.dart';
import 'package:dinar_echange/services/preferences_service.dart';
import 'package:dinar_echange/utils/enums.dart';
import 'package:dinar_echange/utils/logging.dart';
import 'package:dinar_echange/views/settings/legal_view.dart';
import 'package:dinar_echange/widgets/adbanner.dart';

/// Editorial-style settings: tracked-uppercase section labels with
/// hairline rules, generous whitespace, chevron-only tap affordance,
/// version stamp at the foot. No Material list-tile chunk.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        final l10n = AppLocalizations.of(context)!;
        final textDirection = appProvider.currentLocale.languageCode == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.settings_app_bar_title)),
          body: Directionality(
            textDirection: textDirection,
            child: SafeArea(child: _SettingsBody(appProvider: appProvider)),
          ),
        );
      },
    );
  }
}

class _SettingsBody extends StatelessWidget {
  final AppProvider appProvider;
  const _SettingsBody({required this.appProvider});

  static const _languageChoices = <String, String>{
    'English': 'en',
    'العربية': 'ar',
    'Français': 'fr',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLanguageLabel = _languageChoices.entries
        .firstWhere(
          (e) => e.value == appProvider.currentLocale.languageCode,
          orElse: () => const MapEntry('English', 'en'),
        )
        .key;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (kDebugMode)
            _DebugRow(onClear: () async {
              await PreferencesService().clearAllPreferences();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared!')),
                );
              }
            }),

          const SizedBox(height: 8),
          _Section(label: l10n.theme_title),
          const SizedBox(height: 4),
          _ThemeSelector(
            currentTheme: appProvider.themeMode,
            onThemeChanged: appProvider.setThemeMode,
          ),
          const SizedBox(height: 20),
          _NavRow(
            label: l10n.chose_language_title,
            trailing: currentLanguageLabel,
            onTap: () => _openLanguageSheet(context, appProvider),
          ),

          const SizedBox(height: 32),
          _Section(label: l10n.general_title),
          _NavRow(
            label: l10n.rate_us_button,
            onTap: () => InAppReview.instance.openStoreListing(
              appStoreId: 'com.dinarexchange.app',
              microsoftStoreId: '...',
            ),
          ),
          _NavRow(
            label: l10n.about_app_button,
            onTap: () => _openAboutSheet(context, appProvider),
          ),

          const SizedBox(height: 32),
          _Section(label: l10n.legal_title),
          _NavRow(
            label: l10n.terms_title,
            onTap: () => _openLegal(context, LegalDocumentType.terms),
          ),
          _NavRow(
            label: l10n.privacy_title,
            onTap: () => _openLegal(context, LegalDocumentType.privacy),
          ),

          const SizedBox(height: 40),
          _VersionFooter(appProvider: appProvider),
          const SizedBox(height: 16),
          _BottomAd(),
        ],
      ),
    );
  }

  void _openLegal(BuildContext context, LegalDocumentType type) {
    AppLogger.trackScreenView('${type.toString()}_Document', 'Settings');
    AppLogger.logEvent(
        'legal_document_accessed', {'document_type': type.toString()});
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => LegalDocumentsScreen(documentType: type),
    ));
  }

  void _openLanguageSheet(BuildContext context, AppProvider appProvider) {
    AppLogger.trackScreenView('Language_Selection', 'Settings');
    final l10n = AppLocalizations.of(context)!;
    final t = Theme.of(context);
    final currentCode = appProvider.currentLocale.languageCode;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(l10n.chose_language_title,
                    style: t.textTheme.titleLarge),
              ),
              for (final entry in _languageChoices.entries)
                _LanguageRow(
                  label: entry.key,
                  isSelected: entry.value == currentCode,
                  onTap: () {
                    appProvider.setLanguage(Locale(entry.value));
                    AppLogger.logEvent(
                        'language_changed', {'language_code': entry.value});
                    Navigator.of(ctx).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAboutSheet(BuildContext context, AppProvider appProvider) {
    AppLogger.trackScreenView('About_App', 'Settings');
    final l10n = AppLocalizations.of(context)!;
    final t = Theme.of(context);
    final info = appProvider.packageInfo;
    // Locale-agnostic version line — universal dot separators, no
    // English "Version:" / "Build Number:" prefixes.
    final buildMode = appProvider.getBuildMode();
    final versionLine = 'v${info.version} · build ${info.buildNumber} · $buildMode';

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(l10n.about_app_button, style: t.textTheme.titleLarge),
              ),
              const SizedBox(height: 8),
              Text(l10n.about_body, style: t.textTheme.bodyLarge),
              const SizedBox(height: 16),
              Text(versionLine, style: t.textTheme.labelSmall),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _showLicensesPage(context, info.appName, info.version);
                },
                child: Text(l10n.licenses),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLicensesPage(BuildContext context, String appName, String version) {
    AppLogger.trackScreenView('Licenses', 'Settings');
    showLicensePage(
      context: context,
      applicationIcon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Image.asset('assets/logo/light_large.png', scale: 4),
      ),
      applicationName: appName,
      applicationVersion: version,
    );
  }
}

/// Uppercase tracked label followed by a hairline rule — the app's
/// signature structural device on the settings screen.
class _Section extends StatelessWidget {
  final String label;
  const _Section({required this.label});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label.toUpperCase(),
            style: t.textTheme.labelSmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: scheme.outlineVariant),
        ],
      ),
    );
  }
}

/// Interactive row: title on the left, optional trailing value, chevron
/// as the tap affordance. No leading icon — settings are read by label.
class _NavRow extends StatelessWidget {
  final String label;
  final String? trailing;
  final VoidCallback onTap;

  const _NavRow({
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
        child: Row(
          children: [
            Expanded(child: Text(label, style: t.textTheme.bodyLarge)),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: t.textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right, color: scheme.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
        child: Row(
          children: [
            Expanded(child: Text(label, style: t.textTheme.bodyLarge)),
            if (isSelected)
              Icon(Icons.check, color: scheme.onSurface, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final ThemeMode currentTheme;
  final void Function(ThemeOption) onThemeChanged;

  const _ThemeSelector({
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final current = _asOption(currentTheme);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SegmentedButton<ThemeOption>(
        segments: [
          ButtonSegment(
            value: ThemeOption.auto,
            label: FittedBox(child: Text(l10n.auto_button)),
            icon: const Icon(Icons.brightness_auto),
          ),
          ButtonSegment(
            value: ThemeOption.dark,
            label: FittedBox(child: Text(l10n.dark_button)),
            icon: const Icon(Icons.nights_stay),
          ),
          ButtonSegment(
            value: ThemeOption.light,
            label: FittedBox(child: Text(l10n.light_button)),
            icon: const Icon(Icons.wb_sunny),
          ),
        ],
        selected: {current},
        onSelectionChanged: (Set<ThemeOption> next) {
          onThemeChanged(next.first);
          AppLogger.logEvent('theme_changed', {'theme_mode': next.first.name});
        },
      ),
    );
  }

  ThemeOption _asOption(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return ThemeOption.dark;
      case ThemeMode.light:
        return ThemeOption.light;
      case ThemeMode.system:
        return ThemeOption.auto;
    }
  }
}

class _VersionFooter extends StatelessWidget {
  final AppProvider appProvider;
  const _VersionFooter({required this.appProvider});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    final info = appProvider.packageInfo;
    final buildMode = appProvider.getBuildMode();
    return Center(
      child: Column(
        children: [
          Text('Dinar Echange', style: t.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'v${info.version} · build ${info.buildNumber} · $buildMode',
            style: t.textTheme.labelSmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _DebugRow extends StatelessWidget {
  final VoidCallback onClear;
  const _DebugRow({required this.onClear});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: OutlinedButton.icon(
        onPressed: onClear,
        icon: Icon(Icons.delete_forever_outlined, color: scheme.error),
        label: Text('Clear cache (debug)',
            style: t.textTheme.labelMedium?.copyWith(color: scheme.error)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: scheme.error.withValues(alpha: 0.35)),
        ),
      ),
    );
  }
}

class _BottomAd extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ChangeNotifierProvider<AdProvider>(
      create: (_) => AdProvider(),
      child: Consumer<AdProvider>(
        builder: (context, adProvider, _) => Container(
          constraints: const BoxConstraints(minHeight: 60),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: scheme.outlineVariant),
            ),
          ),
          padding: const EdgeInsets.only(top: 8),
          child: const AdBannerWidget(),
        ),
      ),
    );
  }
}
