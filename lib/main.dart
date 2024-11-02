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
  AppLogger.logInfo('Firebase Core initialized.');
  await PreferencesService().init();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const DinarEchange());
}

class DinarEchange extends StatelessWidget {
  const DinarEchange({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final materialTheme = MaterialTheme();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AppInitializationProvider()),
        ChangeNotifierProvider(create: (_) => AdProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: !kReleaseMode,
            debugShowMaterialGrid: false,
            //
            onGenerateTitle: (BuildContext context) =>
                AppLocalizations.of(context)!.app_title,
            //
            theme: materialTheme.light(),
            darkTheme: materialTheme.dark(),
            highContrastTheme: materialTheme.lightHighContrast(),
            highContrastDarkTheme: materialTheme.darkHighContrast(),
            themeMode: appProvider.themeMode,
            //
            locale: appProvider.currentLocale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            //
            home: const AppStartup(),
          );
        },
      ),
    );
  }
}

class AppStartup extends StatelessWidget {
  const AppStartup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppInitializationProvider>(context, listen: false)
          .initializeApp();
    });
    return Consumer<AppInitializationProvider>(
      builder: (context, initProvider, _) {
        if (initProvider.Paralleltate.isLoading ||
            initProvider.officialState.isLoading) {
          return const Scaffold(body: Center(child: LinearProgressIndicator()));
        } else if (initProvider.Paralleltate.isError ||
            initProvider.officialState.isError) {
          return ErrorApp(onRetry: () => initProvider.initializeApp());
        }
        return const AppNavigation();
      },
    );
  }
}
