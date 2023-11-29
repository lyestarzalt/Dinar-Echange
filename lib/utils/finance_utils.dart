import 'package:decimal/decimal.dart';

class FinanceUtils {
  /// Converts an amount from one currency to another using a given rate.
  ///
  /// [amount]: The amount to be converted.
  /// [rate]: The exchange rate for the conversion.
  /// [isDZDtoCurrency]: A boolean to determine the direction of the conversion.
  /// Returns a string representation of the converted amount, formatted to two decimal places.
  static String convertAmount(num amount, num rate, bool isDZDtoCurrency) {
    Decimal conversionRate;

    var dAmount = Decimal.parse(amount.toString());
    var dRate = Decimal.parse(rate.toString());

    if (isDZDtoCurrency) {
      conversionRate =
          Decimal.parse(((Decimal.one / dRate).toDouble()).toString());
    } else {
      conversionRate = dRate;
    }
    Decimal convertedAmount = dAmount * conversionRate;

    return formatDecimal(convertedAmount);
  }

  /// Formats a Decimal number to a string with a specified number of decimal places.
  ///
  /// [number]: The Decimal number to format.
  /// [decimalPlaces]: The number of decimal places to format the number to (default is 2).
  /// Returns a string representation of the number, formatted to the specified decimal places.
  static String formatDecimal(Decimal number, {int decimalPlaces = 2}) {
    return number.toStringAsFixed(decimalPlaces);
  }

  /// Calculates the converted rate between two currencies.
  ///
  /// [baseRate]: The rate of the base currency in DZD.
  /// [rateToBase]: The rate of the target currency to the base currency.
  /// Returns a Decimal representing the converted rate.
  static Decimal calculateConvertedRate(Decimal baseRate, Decimal rateToBase) {
    var result = baseRate / rateToBase;
    return Decimal.parse(result.toString());
  }
}
