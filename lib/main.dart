import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dinar_watch/providers/theme_provider.dart';
import 'package:dinar_watch/providers/language_provider.dart';
import 'package:dinar_watch/services/preferences_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dinar_watch/views/app_navigation.dart';
import 'package:dinar_watch/providers/navigation_provider.dart';
import 'package:dinar_watch/theme/theme.dart';
import 'package:dinar_watch/views/error/error_view.dart';
import 'package:dinar_watch/providers/appinit_provider.dart';
import 'package:dinar_watch/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:dinar_watch/utils/enums.dart';
import 'package:flutter/services.dart';
import 'package:dinar_watch/utils/logging.dart';
import 'package:dinar_watch/providers/admob_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AppLogger.logInfo('Firebase initialized successfully.');

  await PreferencesService().init();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  // The app is only usable in portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_) => runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => LanguageProvider()),
            ChangeNotifierProvider(create: (_) => NavigationProvider()),
            ChangeNotifierProvider(create: (_) => AppInitializationProvider()),
            ChangeNotifierProvider(create: (_) => AdProvider()),
          ],
          child: const DinarWatch(),
        ),
      ));
}

class DinarWatch extends StatefulWidget {
  const DinarWatch({super.key});

  @override
  DinarWatchState createState() => DinarWatchState();
}

class DinarWatchState extends State<DinarWatch> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() =>
        Provider.of<AppInitializationProvider>(context, listen: false)
            .initializeApp());
  }

  @override
  Widget build(BuildContext context) {
    final MaterialTheme materialTheme = MaterialTheme();
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, _) {
        return MaterialApp(
          title: 'Dinar Watch',
          theme: materialTheme.light(),
          darkTheme: materialTheme.dark(),
          themeMode: themeProvider.themeMode,
          highContrastTheme: materialTheme.lightHighContrast(),
          highContrastDarkTheme: materialTheme.darkHighContrast(),
          locale: languageProvider.currentLocale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Consumer<AppInitializationProvider>(
            builder: (context, currenciesProvider, _) {
              switch (currenciesProvider.state.state) {
                case LoadState.loading:
                  return const Scaffold(
                    body: Center(child: LinearProgressIndicator()),
                  );
                case LoadState.success:
                  return AppNavigation(
                      currencies: currenciesProvider.state.data!);
                case LoadState.error:
                  return ErrorApp(
                    errorMessage: currenciesProvider.state.errorMessage!,
                    onRetry: () => currenciesProvider.initializeApp(),
                  );
                default:
                  return const Scaffold(
                    body: Center(child: LinearProgressIndicator()),
                  );
              }
            },
          ),
        );
      },
    );
  }
}
