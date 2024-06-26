import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dinar_echange/providers/app_provider.dart';
import 'package:dinar_echange/services/preferences_service.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:dinar_echange/views/app_navigation.dart';
import 'package:dinar_echange/theme/theme.dart';
import 'package:dinar_echange/views/error/error_view.dart';
import 'package:dinar_echange/providers/appinit_provider.dart';
import 'package:dinar_echange/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:dinar_echange/utils/logging.dart';
import 'package:dinar_echange/providers/admob_provider.dart';
import 'package:flutter/foundation.dart';

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
            ChangeNotifierProvider(create: (_) => AppProvider()),
            ChangeNotifierProvider(create: (_) => AppInitializationProvider()),
            ChangeNotifierProvider(create: (_) => AdProvider()),
          ],
          child: const DinarEchange(),
        ),
      ));
}

class DinarEchange extends StatefulWidget {
  const DinarEchange({super.key});

  @override
  DinarEchangeState createState() => DinarEchangeState();
}

class DinarEchangeState extends State<DinarEchange> {
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
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: !kReleaseMode,
          debugShowMaterialGrid: false,
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.app_title,
          theme: materialTheme.light(),
          darkTheme: materialTheme.dark(),
          themeMode: appProvider.themeMode,
          highContrastTheme: materialTheme.lightHighContrast(),
          highContrastDarkTheme: materialTheme.darkHighContrast(),
          locale: appProvider.currentLocale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Consumer<AppInitializationProvider>(
            builder: (context, currenciesProvider, _) {
              bool isLoading = currenciesProvider.Paralleltate.isLoading &&
                  currenciesProvider.officialState.isLoading;
              bool hasError = currenciesProvider.Paralleltate.isError ||
                  currenciesProvider.officialState.isError;
              if (isLoading) {
                return const Scaffold(
                  body: Center(child: LinearProgressIndicator()),
                );
              } else if (hasError) {
                return ErrorApp(
                  onRetry: () => currenciesProvider.initializeApp(),
                );
              } else {
                return AppNavigation(
                  currencies: currenciesProvider.currencies!,
                  officialCurrencies: currenciesProvider.officialCurrencies!,
                );
              }
            },
          ),
        );
      },
    );
  }
}
