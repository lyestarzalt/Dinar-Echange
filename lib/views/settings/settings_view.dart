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

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  ThemeOption themeOption = ThemeOption.auto;
  String selectedLanguage = 'English'; // default
  Map<String, String> languageCodes = {
    'English': 'en',
    'العربية': 'ar',
    'Français': 'fr',
  };

  @override
  Widget build(BuildContext context) {
    final prefsService = PreferencesService();
    final InAppReview inAppReview = InAppReview.instance;
    final text = AppLocalizations.of(context)!;
    return Scaffold(
        appBar: AppBar(
          title: Text(text.settings_app_bar_title),
        ),
        body:
            Consumer<AppProvider>(builder: (context, languageProvider, child) {
          final textDirection =
              languageProvider.currentLocale.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr;
          return Directionality(
            textDirection: textDirection,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (kDebugMode)
                          ListTile(
                            leading: Icon(Icons.delete_forever),
                            title: Text('Clear Cache (Debug Only)'),
                            onTap: () async {
                              await prefsService.clearAllPreferences();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Cache cleared!')),
                              );
                            },
                          ),
                        buildSectionTitle(context, text.theme_title),
                        _buildThemeSelection(context),
                        const SizedBox(height: 16),
                        buildSectionTitle(context, text.general_title),
                        SettingsItem(
                          icon: Icons.language,
                          text: text.chose_language_title,
                          onTap: () {
                            _showLanguageDialog();
                          },
                        ),
                        SettingsItem(
                          icon: Icons.star,
                          text: text.rate_us_button,
                          onTap: () {
                            inAppReview.openStoreListing(
                                appStoreId: 'com.dinarexchange.app',
                                microsoftStoreId: '...');
                          },
                        ),
                        SettingsItem(
                          icon: Icons.info_outline,
                          text: text.about_app_button,
                          onTap: () {
                            _showAboutDialog(context);
                          },
                        ),
                        ChangeNotifierProvider<AdProvider>(
                          create: (_) => AdProvider(),
                          child: Consumer<AdProvider>(
                            builder: (context, adProvider, _) => ConstrainedBox(
                              constraints: BoxConstraints(minHeight: 50),
                              child: const AdBannerWidget(),
                            ),
                          ),
                        ),
                        buildSectionTitle(context, text.legal_title),
                        SettingsItem(
                          icon: Icons.article,
                          text: text.terms_title,
                          onTap: () =>
                              _openLegalDocument(LegalDocumentType.terms),
                        ),
                        SettingsItem(
                          icon: Icons.privacy_tip,
                          text: text.privacy_title,
                          onTap: () =>
                              _openLegalDocument(LegalDocumentType.privacy),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  )),
            ),
          );
        }));
  }

  void _openLegalDocument(LegalDocumentType type) {
    AppLogger.trackScreenView('${type.toString()}_Document', 'Settings');
    AppLogger.logEvent('legal_document_accessed', {
      'document_type': type.toString(),
    });

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => LegalDocumentsScreen(documentType: type),
    ));
  }

  Widget buildSectionTitle(BuildContext context, String title) {
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

  Widget _buildThemeSelection(BuildContext context) {
    final text = AppLocalizations.of(context)!;
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        ThemeOption currentThemeOption = ThemeOption.auto; // Default
        switch (appProvider.themeMode) {
          case ThemeMode.dark:
            currentThemeOption = ThemeOption.dark;
            break;
          case ThemeMode.light:
            currentThemeOption = ThemeOption.light;
            break;
          case ThemeMode.system:
            currentThemeOption = ThemeOption.auto;
            break;
        }

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
            child: SegmentedButton(
              segments: <ButtonSegment>[
                ButtonSegment(
                    value: ThemeOption.auto,
                    label: Text(text.auto_button),
                    icon: const Icon(Icons.brightness_auto)),
                ButtonSegment(
                    value: ThemeOption.dark,
                    label: Text(text.dark_button),
                    icon: const Icon(Icons.nights_stay)),
                ButtonSegment(
                    value: ThemeOption.light,
                    label: Text(text.light_button),
                    icon: const Icon(Icons.wb_sunny)),
              ],
              selected: {currentThemeOption},
              onSelectionChanged: (Set newSelection) {
                ThemeOption selectedOption = newSelection.first;
                appProvider.setThemeMode(selectedOption);
                AppLogger.logEvent('theme_changed', {
                  'theme_mode': selectedOption.name,
                });
              },
            ),
          ),
        );
      },
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        AppLogger.trackScreenView('Language_Selection', 'Settings');

        return Consumer<AppProvider>(
          builder: (context, appProvider, child) {
            String currentLanguage = languageCodes.entries
                .firstWhere(
                  (entry) =>
                      entry.value == appProvider.currentLocale.languageCode,
                  orElse: () => const MapEntry('English', 'en'),
                )
                .key;
            final text = AppLocalizations.of(context)!;
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
                          appProvider.setLanguage(
                              Locale(languageCodes[value] ?? 'en'));
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
              actions: <Widget>[
                TextButton(
                  child: Text(text.close_button),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    AppLogger.trackScreenView('About_App', 'Settings');

    final text = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<AppProvider>(
          builder: (context, provider, child) {
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
                    Text('Version: ${provider.packageInfo.version}'),
                    Text('Build Number: ${provider.packageInfo.buildNumber}'),
                    Text('Build Mode: ${provider.getBuildMode()}'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(text.licenses),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showLicensesPage(context, provider.packageInfo.appName,
                        provider.packageInfo.version);
                  },
                ),
                TextButton(
                  child: Text(text.close_button),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
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
