import 'package:flutter/material.dart';
import 'package:dinar_watch/shared/enums.dart';
import 'package:dinar_watch/pages/home_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dinar_watch/services/preferences_service.dart';

class SettingsPage extends StatefulWidget {
  final void Function(ThemeOption) onThemeChanged;

  const SettingsPage({Key? key, required this.onThemeChanged});

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

  void _loadSelectedLanguage() async {
    String languageCode =
        await PreferencesService().getSelectedLanguage() ?? 'en';
    ThemeMode savedThemeMode = await PreferencesService().getThemeMode();

    ThemeOption savedThemeOption;
    switch (savedThemeMode) {
      case ThemeMode.dark:
        savedThemeOption = ThemeOption.dark;
        break;
      case ThemeMode.light:
        savedThemeOption = ThemeOption.light;
        break;
      default:
        savedThemeOption = ThemeOption.auto;
    }

    setState(() {
      selectedLanguage = languageCodes.entries
          .firstWhere(
            (entry) => entry.value == languageCode,
            orElse: () => const MapEntry('English', 'en'),
          )
          .key;
      themeOption = savedThemeOption;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

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
              _buildThemeSelection(),
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

  Widget _buildThemeSelection() {
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
            selected: {themeOption},
            onSelectionChanged: (Set newSelection) async {
              themeOption = newSelection.first;

              await PreferencesService().setThemeMode(themeOption);
              setState(() {
                themeOption = newSelection.first;
                widget.onThemeChanged(themeOption);
              });
            },
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
    String languageCode = languageCodes[languageName] ?? 'en';
    await PreferencesService().setSelectedLanguage(languageCode);

    final mainScreenState = context.findAncestorStateOfType<MainScreenState>();
    mainScreenState?.setLocale(Locale(languageCode));
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: languageCodes.entries
                  .map(
                      (MapEntry<String, String> entry) => RadioListTile<String>(
                            title: Text(entry.key), // Language name
                            value: entry.key, // Language name as value
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
}
