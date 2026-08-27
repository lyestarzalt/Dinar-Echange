import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dinar_echange/providers/app_provider.dart';
import 'package:dinar_echange/services/preferences_service.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:dinar_echange/views/app_navigation.dart';
import 'package:dinar_echange/theme/theme.dart';
import 'package:dinar_echange/views/error/error_view.dart';
import 'package:dinar_echange/widgets/skeletons.dart';
import 'package:dinar_echange/providers/appinit_provider.dart';
import 'package:dinar_echange/utils/enums.dart';
import 'package:dinar_echange/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:dinar_echange/utils/logging.dart';
import 'package:dinar_echange/providers/admob_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Keep the native splash on-screen until AppInitializationProvider tears
  // it down after the first real frame is rendered.
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AppLogger.logInfo('Firebase Core initialized.');
  await PreferencesService().init();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // Kick off the daily-rates fetch before runApp so the network work overlaps
  // with the widget tree building.
  final appInit = AppInitializationProvider()..initializeApp();

  runApp(DinarEchange(appInit: appInit));
}

class DinarEchange extends StatelessWidget {
  const DinarEchange({super.key, required this.appInit});

  final AppInitializationProvider appInit;

  @override
  Widget build(BuildContext context) {
    final materialTheme = MaterialTheme();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider.value(value: appInit),
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
            builder: (context, child) {
              // Clamp Dynamic Type / font-scale so the 64pt hero rate
              // doesn't overflow the card at extreme accessibility
              // sizes — but still let users scale up meaningfully.
              final mq = MediaQuery.of(context);
              final clamped = mq.copyWith(
                textScaler: mq.textScaler
                    .clamp(minScaleFactor: 0.9, maxScaleFactor: 1.3),
              );
              return MediaQuery(
                data: clamped,
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const AppStartup(),
          );
        },
      ),
    );
  }
}

class AppStartup extends StatelessWidget {
  const AppStartup({super.key});

  @override
  Widget build(BuildContext context) {
    // Only listen to the two LoadState fields we branch on. Locale /
    // theme / package-info notifies on AppInit no longer rebuild the
    // whole startup switch.
    return Selector<AppInitializationProvider, ({LoadState p, LoadState o})>(
      selector: (_, provider) => (
        p: provider.parallelState.state,
        o: provider.officialState.state,
      ),
      builder: (context, states, _) {
        final loading = states.p == LoadState.loading ||
            states.o == LoadState.loading;
        final error =
            states.p == LoadState.error || states.o == LoadState.error;
        if (loading) {
          // On first launch the native splash is still covering this widget.
          // On a manual retry from ErrorApp, the splash is already gone, so
          // the skeleton takes over.
          return const Scaffold(body: CurrencyListSkeleton());
        } else if (error) {
          // Use listen:false — the retry callback doesn't need to hold a
          // dependency here.
          return ErrorApp(
            onRetry: () => Provider.of<AppInitializationProvider>(context,
                    listen: false)
                .initializeApp(),
          );
        }
        return const AppNavigation();
      },
    );
  }
}
