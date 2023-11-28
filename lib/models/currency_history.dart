import 'currency.dart';

class CurrencyHistory {
  final String name;
  List<Currency> history;

  CurrencyHistory({required this.name, required List<Currency> history})
      : history = _sortHistory(history);

  static List<Currency> _sortHistory(List<Currency> history) {
    // Sort the history list by date in ascending order
    history.sort((a, b) => a.date.compareTo(b.date));
    return history;
  }
}
