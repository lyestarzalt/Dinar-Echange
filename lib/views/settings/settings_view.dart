import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
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

/// Settings screen. Structure follows Flutter's idiomatic patterns:
///   - Scaffold + Material AppBar on Android, CustomScrollView +
///     CupertinoSliverNavigationBar on iOS for the large-title look.
///   - Items are standard ListTiles, which carry their own Material
///     ancestry so we don't have to fight "No Material widget found"
///     inside every popup.
///   - Popups use showModalBottomSheet on both platforms — its builder
///     inherits the app's BottomSheetThemeData (paper background,
///     rounded top, drag handle) and provides Material context by
///     default.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const _languageChoices = <String, String>{
    'English': 'en',
    'العربية': 'ar',
    'Français': 'fr',
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        final l10n = AppLocalizations.of(context)!;
        final textDirection = appProvider.currentLocale.languageCode == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr;
        final title = l10n.settings_app_bar_title;
        final items = _items(context, appProvider);

        return Directionality(
          textDirection: textDirection,
          child: Platform.isIOS
              ? Scaffold(
                  body: CustomScrollView(
                    slivers: [
                      CupertinoSliverNavigationBar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surface
                            .withValues(alpha: 0.72),
                        largeTitle: Text(title),
                      ),
                      SliverSafeArea(
                        top: false,
                        sliver: SliverList.list(children: items),
                      ),
                    ],
                  ),
                )
              : Scaffold(
                  appBar: AppBar(title: Text(title)),
                  body: SafeArea(child: ListView(children: items)),
                ),
        );
      },
    );
  }

  List<Widget> _items(BuildContext context, AppProvider appProvider) {
    final l10n = AppLocalizations.of(context)!;
    final currentLanguageLabel = _languageChoices.entries
        .firstWhere(
          (e) => e.value == appProvider.currentLocale.languageCode,
          orElse: () => const MapEntry('English', 'en'),
        )
        .key;

    return [
      if (kDebugMode) _DebugTile(),
      const SizedBox(height: 8),

      _SectionHeader(l10n.theme_title),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: _ThemeSelector(
          currentTheme: appProvider.themeMode,
          onThemeChanged: appProvider.setThemeMode,
        ),
      ),
      ListTile(
        title: Text(l10n.chose_language_title),
        trailing: Text(currentLanguageLabel),
        onTap: () => _openLanguageSheet(context, appProvider),
      ),

      const SizedBox(height: 24),
      _SectionHeader(l10n.general_title),
      ListTile(
        title: Text(l10n.rate_us_button),
        onTap: () => InAppReview.instance.openStoreListing(
          appStoreId: 'com.dinarexchange.app',
          microsoftStoreId: '...',
        ),
      ),
      ListTile(
        title: Text(l10n.about_app_button),
        onTap: () => _openAbout(context, appProvider),
      ),

      const SizedBox(height: 24),
      _SectionHeader(l10n.legal_title),
      ListTile(
        title: Text(l10n.terms_title),
        onTap: () => _openLegal(context, LegalDocumentType.terms),
      ),
      ListTile(
        title: Text(l10n.privacy_title),
        onTap: () => _openLegal(context, LegalDocumentType.privacy),
      ),

      const SizedBox(height: 40),
      _VersionFooter(appProvider: appProvider),
      const SizedBox(height: 16),
      _BottomAd(),
    ];
  }

  void _openLegal(BuildContext context, LegalDocumentType type) {
    AppLogger.trackScreenView('${type.toString()}_Document', 'Settings');
    AppLogger.logEvent(
      'legal_document_accessed',
      {'document_type': type.toString()},
    );
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => LegalDocumentsScreen(documentType: type),
    ));
  }

  void _openLanguageSheet(BuildContext context, AppProvider appProvider) {
    AppLogger.trackScreenView('Language_Selection', 'Settings');
    final l10n = AppLocalizations.of(context)!;
    final t = Theme.of(context);
    final currentCode = appProvider.currentLocale.languageCode;

    // Standard modal bottom sheet — inherits BottomSheetThemeData from
    // the theme (paper background, rounded top, drag handle), provides
    // Material context automatically. Works identically on iOS and
    // Android without special casing.
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: RadioGroup<String>(
          groupValue: currentCode,
          onChanged: (v) {
            if (v == null) return;
            appProvider.setLanguage(Locale(v));
            AppLogger.logEvent('language_changed', {'language_code': v});
            Navigator.of(ctx).pop();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(l10n.chose_language_title,
                    style: t.textTheme.titleLarge),
              ),
              for (final entry in _languageChoices.entries)
                RadioListTile<String>.adaptive(
                  title: Text(entry.key),
                  value: entry.value,
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _openAbout(BuildContext context, AppProvider appProvider) {
    AppLogger.trackScreenView('About_App', 'Settings');
    final l10n = AppLocalizations.of(context)!;
    final info = appProvider.packageInfo;

    // Use Flutter's built-in about dialog — it provides Material +
    // Cupertino-adaptive presentation, a proper Licenses button that
    // routes to the license page, and shows the app name + version
    // consistently across platforms.
    showAboutDialog(
      context: context,
      applicationName: info.appName,
      applicationVersion:
          'v${info.version} · build ${info.buildNumber} · ${appProvider.getBuildMode()}',
      applicationIcon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Image.asset('assets/logo/light_large.png',
            width: 48, height: 48),
      ),
      children: [
        const SizedBox(height: 12),
        Text(l10n.about_body),
      ],
    );
  }
}

/// Tracked-uppercase section label. Sits directly above its group of
/// ListTiles.
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        label.toUpperCase(),
        style: t.textTheme.labelSmall
            ?.copyWith(color: scheme.onSurfaceVariant),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SegmentedButton<ThemeOption>(
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
      selected: {_asOption(currentTheme)},
      onSelectionChanged: (next) {
        onThemeChanged(next.first);
        AppLogger.logEvent('theme_changed', {'theme_mode': next.first.name});
      },
    );
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
    return Center(
      child: Column(
        children: [
          Text('Dinar Echange', style: t.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'v${info.version} · build ${info.buildNumber} · ${appProvider.getBuildMode()}',
            style: t.textTheme.labelSmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _DebugTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(Icons.delete_forever_outlined, color: scheme.error),
      title: Text(
        'Clear cache (debug)',
        style: TextStyle(color: scheme.error),
      ),
      onTap: () async {
        await PreferencesService().clearAllPreferences();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cache cleared!')),
          );
        }
      },
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
            border: Border(top: BorderSide(color: scheme.outlineVariant)),
          ),
          padding: const EdgeInsets.only(top: 8),
          child: const AdBannerWidget(),
        ),
      ),
    );
  }
}
