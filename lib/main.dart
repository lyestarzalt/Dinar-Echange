import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dinar_watch/providers/theme_provider.dart';
import 'package:dinar_watch/providers/language_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:dinar_watch/data/repositories/main_repository.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:dinar_watch/services/preferences_service.dart';
import 'package:dinar_watch/theme/color_scheme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dinar_watch/pages/home_screen.dart';
import 'package:dinar_watch/providers/navigation_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DinarWatch());
}

class DinarWatch extends StatefulWidget {
  const DinarWatch({super.key});

  @override
  DinarWatchState createState() => DinarWatchState();
}

class DinarWatchState extends State<DinarWatch> {
  late Future<List<Currency>> _currenciesFuture;

  @override
  void initState() {
    super.initState();
    _currenciesFuture = initializeApp();
  }

  Future<List<Currency>> initializeApp() async {
    FlutterNativeSplash.preserve(
        widgetsBinding: WidgetsFlutterBinding.ensureInitialized());
    await PreferencesService().init();

    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      await FirebaseAuth.instance.signInAnonymously();
      List<Currency> todayCurrencies =
          await MainRepository().getDailyCurrencies();
      FlutterNativeSplash.remove();
      return todayCurrencies;
    } catch (e) {
      FlutterNativeSplash.remove();
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Currency>>(
      future: _currenciesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => ThemeProvider()),
              ChangeNotifierProvider(create: (_) => LanguageProvider()),
              ChangeNotifierProvider(create: (_) => NavigationProvider())
            ],
            child: Consumer2<ThemeProvider, LanguageProvider>(
              builder: (context, themeProvider, languageProvider, _) {
                return MaterialApp(
                  title: 'Dinar Watch',
                  theme: ColorSchemeManager.lightTheme,
                  darkTheme: ColorSchemeManager.darkTheme,
                  themeMode: themeProvider.themeMode,
                  locale: languageProvider.currentLocale,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  home: MainScreen(currencies: snapshot.data ?? []),
                );
              },
            ),
          );
        } else {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: LinearProgressIndicator()),
            ),
          );
        }
      },
    );
  }
}
