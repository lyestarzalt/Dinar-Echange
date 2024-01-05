import 'package:flutter/material.dart';
import 'package:dinar_watch/shared/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dinar_watch/pages/home_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  final void Function(ThemeOption) onThemeChanged;

  const SettingsPage({Key? key, required this.onThemeChanged});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  ThemeOption themeOption = ThemeOption.auto;
  List<String> languages = [
    'English',
    'العربية',
    'Deutsch',
    'Español',
    'Français',
    '中文'
  ];

  Map<String, String> languageCodes = {
    'English': 'en',
    'العربية': 'ar',
    'Español': 'es',
    'Deutsch': 'de',
    'Français': 'fr',
    '中文': 'zh',

   
  };

  String selectedLanguage = 'English'; // default

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
              Padding(
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
                      selected: {themeOption},
                      onSelectionChanged: (Set newSelection) {
                        setState(() {
                          themeOption = newSelection.first;
                          widget.onThemeChanged(themeOption);
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(AppLocalizations.of(context)!.general,
                  style: const TextStyle(fontSize: 15)),
              const Divider(thickness: 2),
              _buildRateUsRow(),
              _buildAboutUsRow(context),
              _buildLanguageRow(),
              Text(AppLocalizations.of(context)!.currencies)
            ],
          ),
        ),
      ),
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

  void _changeLanguage(String languageName) async {
    String languageCode =
        languageCodes[languageName] ?? 'en'; // Default to 'en' if not found

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', languageCode);

    final mainScreenState = context.findAncestorStateOfType<MainScreenState>();
    mainScreenState?.setLocale(Locale(languageCode));
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.chose_language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages
                .map((String language) => RadioListTile<String>(
                      title: Text(language),
                      value: language,
                      groupValue: selectedLanguage,
                      onChanged: (String? value) {
                        setState(() {
                          selectedLanguage = value!;
                          Navigator.of(context).pop();
                          _changeLanguage(selectedLanguage);
                        });
                      },
                    ))
                .toList(),
          ),
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

  Widget _buildAboutUsRow(BuildContext context) {
    return InkWell(
      onTap: () => _showAboutDialog(context),
      child: Padding(
        padding: const EdgeInsets.all(8.0), 
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline,
                size: 24.0), 
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
}
