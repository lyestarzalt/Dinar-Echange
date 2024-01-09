import 'package:flutter/material.dart';
import 'package:dinar_watch/utils/enums.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dinar_watch/providers/language_provider.dart';
import 'package:dinar_watch/providers/theme_provider.dart';

import 'package:provider/provider.dart';

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
    'Español': 'es',
    'Deutsch': 'de',
    'Français': 'fr',
    '中文': 'zh',
  };





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(AppLocalizations.of(context)!.theme,
                  style: const TextStyle(fontSize: 15)),
              const Divider(thickness: 2),
              _buildThemeSelection(context),
              const SizedBox(height: 10),
              Text(AppLocalizations.of(context)!.general,
                  style: const TextStyle(fontSize: 15)),
              const Divider(thickness: 2),
              _buildRateUsRow(),
              _buildAboutUsRow(context),
              _buildLanguageRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelection(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        ThemeOption currentThemeOption = ThemeOption.auto; // Default
        switch (themeProvider.themeMode) {
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

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Theme(
              data: Theme.of(context).copyWith(
                outlinedButtonTheme: OutlinedButtonThemeData(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              child: SegmentedButton(
                segments: <ButtonSegment>[
                  ButtonSegment(
                      value: ThemeOption.auto,
                      label: Text(AppLocalizations.of(context)!.auto),
                      icon: const Icon(Icons.brightness_auto)),
                  ButtonSegment(
                      value: ThemeOption.dark,
                      label: Text(AppLocalizations.of(context)!.dark),
                      icon: const Icon(Icons.nights_stay)),
                  ButtonSegment(
                      value: ThemeOption.light,
                      label: Text(AppLocalizations.of(context)!.light),
                      icon: const Icon(Icons.wb_sunny)),
                ],
                selected: {currentThemeOption},
                onSelectionChanged: (Set newSelection) {
                  ThemeOption selectedOption = newSelection.first;
                  themeProvider.setThemeMode(selectedOption);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageRow() {
    return InkWell(
      onTap: _showLanguageDialog,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 24.0),
            const SizedBox(width: 10),
            Text(AppLocalizations.of(context)!.languages,
                style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            String currentLanguage = languageCodes.entries
                .firstWhere(
                  (entry) =>
                      entry.value ==
                      languageProvider.currentLocale.languageCode,
                  orElse: () => const MapEntry('English', 'en'),
                )
                .key;

            return Dialog(
              child: Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: languageCodes.entries
                      .map((MapEntry<String, String> entry) =>
                          RadioListTile<String>(
                            title: Text(entry.key), // Language name
                            value: entry.key, // Language name as value
                            groupValue: currentLanguage,
                            onChanged: (String? value) {
                              if (value != null) {
                                languageProvider.setLanguage(
                                    Locale(languageCodes[value] ?? 'en'));
                                Navigator.of(context).pop();
                              }
                            },
                          ))
                      .toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildAboutUsRow(BuildContext context) {
    return InkWell(
      onTap: () => _showAboutDialog(context),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 24.0),
            const SizedBox(width: 10),
            Text(AppLocalizations.of(context)!.about_app,
                style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.about_app),
          content: SingleChildScrollView(
            child: Text(AppLocalizations.of(context)!.about_body),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRateUsRow() {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, size: 24.0),
            const SizedBox(width: 10),
            Text(AppLocalizations.of(context)!.rate_us,
                style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
