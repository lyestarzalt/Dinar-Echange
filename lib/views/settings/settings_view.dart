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
          title: Text(AppLocalizations.of(context)!.settings_app_bar_title),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildSectionTitle(
                      context, AppLocalizations.of(context)!.theme_title),
                  _buildThemeSelection(context),
                  buildSectionTitle(
                      context, AppLocalizations.of(context)!.general_title),
                  SettingsItem(
                    icon: Icons.language,
                    text: AppLocalizations.of(context)!.chose_language_title,
                    onTap: () {
                      _showLanguageDialog();
                    },
                  ),
                  SettingsItem(
                    icon: Icons.star,
                    text: AppLocalizations.of(context)!.rate_us_button,
                    onTap: () {
                      // Rate us action
                    },
                  ),
                  SettingsItem(
                    icon: Icons.info_outline,
                    text: AppLocalizations.of(context)!.about_app_button,
                    onTap: () {
                      _showAboutDialog(context);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              )),
        ));
  }

  Widget buildSectionTitle(BuildContext context, String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Divider(thickness: 2),
        ],
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
          child: SegmentedButton(
            segments: <ButtonSegment>[
              ButtonSegment(
                  value: ThemeOption.auto,
                  label: Text(AppLocalizations.of(context)!.auto_button),
                  icon: const Icon(Icons.brightness_auto)),
              ButtonSegment(
                  value: ThemeOption.dark,
                  label: Text(AppLocalizations.of(context)!.dark_button),
                  icon: const Icon(Icons.nights_stay)),
              ButtonSegment(
                  value: ThemeOption.light,
                  label: Text(AppLocalizations.of(context)!.light_button),
                  icon: const Icon(Icons.wb_sunny)),
            ],
            selected: {currentThemeOption},
            onSelectionChanged: (Set newSelection) {
              ThemeOption selectedOption = newSelection.first;
              themeProvider.setThemeMode(selectedOption);
            },
          ),
        );
      },
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

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(AppLocalizations.of(context)!.chose_language_title),
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
                          languageProvider.setLanguage(
                              Locale(languageCodes[value] ?? 'en'));
                          Navigator.of(context).pop();
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(AppLocalizations.of(context)!.close_button),
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(AppLocalizations.of(context)!.about_app_button),
          content: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 8.0),
            child: ListBody(
              children: [
                Text(AppLocalizations.of(context)!.about_body),
                const SizedBox(height: 16),
                const Text('Version: 1.0.0'), // Replace with your app version
                // Add more info here if needed
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.close_button),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final double verticalPadding;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.verticalPadding = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24.0),
            const SizedBox(width: 16),
            Text(text, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
