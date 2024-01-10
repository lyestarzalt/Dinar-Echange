
import 'package:flutter/material.dart';
import 'package:dinar_watch/data/repositories/main_repository.dart';
import 'package:dinar_watch/data/models/currency.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dinar_watch/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';


class AppInitializationProvider with ChangeNotifier {
  CurrenciesState _state = CurrenciesState.loading();

  CurrenciesState get state => _state;
  List<Currency>? get currencies => _state.currencies;

  Future<void> initializeApp() async {
    FlutterNativeSplash.preserve(
        widgetsBinding: WidgetsFlutterBinding.ensureInitialized());
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      await FirebaseAuth.instance.signInAnonymously();
      List<Currency> fetchedCurrencies =
          await MainRepository().getDailyCurrencies();
      _state = CurrenciesState.success(fetchedCurrencies);
    } catch (e) {
      _state = CurrenciesState.error(e.toString());
    } finally {
      FlutterNativeSplash.remove();
      notifyListeners();
    }
  }
}
enum LoadState { loading, success, error }

class CurrenciesState {
  LoadState state;
  List<Currency>? currencies;
  String? errorMessage;

  CurrenciesState._({required this.state, this.currencies, this.errorMessage});

  factory CurrenciesState.loading() =>
      CurrenciesState._(state: LoadState.loading);

  factory CurrenciesState.success(List<Currency> currencies) =>
      CurrenciesState._(state: LoadState.success, currencies: currencies);

  factory CurrenciesState.error(String message) =>
      CurrenciesState._(state: LoadState.error, errorMessage: message);
}
