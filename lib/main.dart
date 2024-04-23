import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dinar_echange/providers/theme_provider.dart';
import 'package:dinar_echange/providers/language_provider.dart';
import 'package:dinar_echange/services/preferences_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dinar_echange/views/app_navigation.dart';
import 'package:dinar_echange/providers/navigation_provider.dart';
import 'package:dinar_echange/theme/theme.dart';
import 'package:dinar_echange/views/error/error_view.dart';
import 'package:dinar_echange/providers/appinit_provider.dart';
import 'package:dinar_echange/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:dinar_echange/utils/enums.dart';
import 'package:flutter/services.dart';
import 'package:dinar_echange/utils/logging.dart';
import 'package:dinar_echange/providers/admob_provider.dart';
import 'package:dinar_echange/providers/terms_provider.dart';

import 'package:dinar_echange/views/terms_condition.dart';
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
            builder: (context, appInitProvider, _) {
              switch (appInitProvider.state.state) {
                case LoadState.loading:
                  return const Scaffold(
                    body: Center(child: LinearProgressIndicator()),
                  );
                case LoadState.success:
                  return AppNavigation(currencies: appInitProvider.currencies!);
                case LoadState.error:
                  if (appInitProvider.state.errorMessage ==
                      'Terms not accepted') {
                      
                    return TermsAndConditionsScreen(
                      onUserDecision: (accepted) async {
                        if (accepted) {
                          await PreferencesService().setAcceptedTerms(true);
                          appInitProvider.initializeApp();
                        } else {
                          SystemNavigator.pop();
                        }
                      },
                    );
                  } else {
                    return ErrorApp(
                      errorMessage: appInitProvider.state.errorMessage!,
                      onRetry: () => appInitProvider.initializeApp(),
                    );
                  }
                default:
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
              }
            },
          ),

        );
      },
    );
  }
}
