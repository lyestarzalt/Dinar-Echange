import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dinar_watch/providers/theme_provider.dart';
import 'package:dinar_watch/providers/language_provider.dart';
import 'package:dinar_watch/services/preferences_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dinar_watch/views/home_view.dart';
import 'package:dinar_watch/providers/navigation_provider.dart';
import 'package:dinar_watch/theme/theme.dart';
import 'package:dinar_watch/views/error/error_view.dart';
import 'package:dinar_watch/utils/app_state.dart';
import 'package:dinar_watch/providers/currencies_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => AppInitializationProvider()),
      ],
      child: const DinarWatch(),
    ),
  );
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
    final MaterialTheme materialTheme =
        MaterialTheme(ThemeData.light().textTheme);
    final currencies =
        Provider.of<AppInitializationProvider>(context).currencies;

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
                  return MainScreen(currencies: currencies!);
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
