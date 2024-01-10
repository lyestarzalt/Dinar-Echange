
import 'package:dinar_watch/data/models/currency.dart';

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
