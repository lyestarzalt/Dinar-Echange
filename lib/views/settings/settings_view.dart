import 'package:flutter/material.dart';
import 'package:dinar_echange/utils/enums.dart';
import 'package:provider/provider.dart';
import 'package:dinar_echange/widgets/adbanner.dart';
import 'package:dinar_echange/views/settings/legal_view.dart';
import 'package:dinar_echange/providers/app_provider.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:dinar_echange/services/preferences_service.dart';
import 'package:flutter/foundation.dart';
import 'package:dinar_echange/utils/logging.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:dinar_echange/providers/admob_provider.dart';
import 'package:dinar_echange/widgets/settings_item.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        final text = AppLocalizations.of(context)!;
        final textDirection = appProvider.currentLocale.languageCode == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr;

        return Scaffold(
          appBar: AppBar(
            title: Text(text.settings_app_bar_title),
          ),
          body: Directionality(
            textDirection: textDirection,
            child: SafeArea(
              child: SettingsContent(appProvider: appProvider),
            ),
          ),
        );
      },
    );
  }
}

class SettingsContent extends StatelessWidget {
  final AppProvider appProvider;
  static const Map<String, String> languageCodes = {
    'English': 'en',
    'العربية': 'ar',
    'Français': 'fr',
  };

  const SettingsContent({
    super.key,
    required this.appProvider,
  });

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context)!;
    final inAppReview = InAppReview.instance;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (kDebugMode)
              _DebugSection(
                onClear: () async {
                  await PreferencesService().clearAllPreferences();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cache cleared!')),
                    );
                  }
                },
              ),
            _buildSectionTitle(text.theme_title),
            _ThemeSelector(
              currentTheme: appProvider.themeMode,
              onThemeChanged: (ThemeOption option) {
                appProvider.setThemeMode(option);
              },
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(text.general_title),
            SettingsItem(
              icon: Icons.language,
              text: text.chose_language_title,
              onTap: () => _showLanguageDialog(context, appProvider),
            ),
            SettingsItem(
              icon: Icons.star,
              text: text.rate_us_button,
              onTap: () {
                inAppReview.openStoreListing(
                  appStoreId: 'com.dinarexchange.app',
                  microsoftStoreId: '...',
                );
              },
            ),
            SettingsItem(
              icon: Icons.info_outline,
              text: text.about_app_button,
              onTap: () => _showAboutDialog(context, appProvider),
            ),
            _buildAdBanner(),
            _buildSectionTitle(text.legal_title),
            SettingsItem(
              icon: Icons.article,
              text: text.terms_title,
              onTap: () => _openLegalDocument(context, LegalDocumentType.terms),
            ),
            SettingsItem(
              icon: Icons.privacy_tip,
              text: text.privacy_title,
              onTap: () =>
                  _openLegalDocument(context, LegalDocumentType.privacy),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 20, 0, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Divider(thickness: 2),
        ],
      ),
    );
  }

  Widget _buildAdBanner() {
    return ChangeNotifierProvider<AdProvider>(
      create: (_) => AdProvider(),
      child: Consumer<AdProvider>(
        builder: (context, adProvider, _) => ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 50),
          child: const AdBannerWidget(),
        ),
      ),
    );
  }

  void _openLegalDocument(BuildContext context, LegalDocumentType type) {
    AppLogger.trackScreenView('${type.toString()}_Document', 'Settings');
    AppLogger.logEvent('legal_document_accessed', {
      'document_type': type.toString(),
    });

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => LegalDocumentsScreen(documentType: type),
    ));
  }

  void _showLanguageDialog(BuildContext context, AppProvider appProvider) {
    final text = AppLocalizations.of(context)!;
    AppLogger.trackScreenView('Language_Selection', 'Settings');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String currentLanguage = languageCodes.entries
            .firstWhere(
              (entry) => entry.value == appProvider.currentLocale.languageCode,
              orElse: () => const MapEntry('English', 'en'),
            )
            .key;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(text.chose_language_title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: languageCodes.entries.map((entry) {
                return RadioListTile<String>(
                  title: Text(entry.key),
                  value: entry.key,
                  groupValue: currentLanguage,
                  onChanged: (String? value) {
                    if (value != null) {
                      appProvider
                          .setLanguage(Locale(languageCodes[value] ?? 'en'));
                      AppLogger.logEvent('language_changed', {
                        'language_code': languageCodes[value] ?? 'en',
                      });
                      Navigator.of(context).pop();
                    }
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: Text(text.close_button),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context, AppProvider appProvider) {
    final text = AppLocalizations.of(context)!;
    AppLogger.trackScreenView('About_App', 'Settings');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(text.about_app_button),
          content: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 8.0),
            child: ListBody(
              children: [
                Text(text.about_body),
                const SizedBox(height: 16),
                Text('Version: ${appProvider.packageInfo.version}'),
                Text('Build Number: ${appProvider.packageInfo.buildNumber}'),
                Text('Build Mode: ${appProvider.getBuildMode()}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(text.licenses),
              onPressed: () {
                Navigator.of(context).pop();
                _showLicensesPage(
                  context,
                  appProvider.packageInfo.appName,
                  appProvider.packageInfo.version,
                );
              },
            ),
            TextButton(
              child: Text(text.close_button),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
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

class _DebugSection extends StatelessWidget {
  final VoidCallback onClear;

  const _DebugSection({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.delete_forever),
      title: const Text('Clear Cache (Debug Only)'),
      onTap: onClear,
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final ThemeMode currentTheme;
  final Function(ThemeOption) onThemeChanged;

  const _ThemeSelector({
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context)!;
    ThemeOption currentThemeOption = _getCurrentThemeOption(currentTheme);

    return Theme(
      data: Theme.of(context).copyWith(
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
        child: SegmentedButton<ThemeOption>(
          segments: [
            ButtonSegment(
              value: ThemeOption.auto,
              label: FittedBox(child: Text(text.auto_button)),
              icon: const Icon(Icons.brightness_auto),
            ),
            ButtonSegment(
              value: ThemeOption.dark,
              label: FittedBox(child: Text(text.dark_button)),
              icon: const Icon(Icons.nights_stay),
            ),
            ButtonSegment(
              value: ThemeOption.light,
              label: FittedBox(child: Text(text.light_button)),
              icon: const Icon(Icons.wb_sunny),
            ),
          ],
          selected: {currentThemeOption},
          onSelectionChanged: (Set<ThemeOption> newSelection) {
            onThemeChanged(newSelection.first);
            AppLogger.logEvent('theme_changed', {
              'theme_mode': newSelection.first.name,
            });
          },
        ),
      ),
    );
  }

  ThemeOption _getCurrentThemeOption(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return ThemeOption.dark;
      case ThemeMode.light:
        return ThemeOption.light;
      case ThemeMode.system:
      default:
        return ThemeOption.auto;
    }
  }
}
