import 'dart:convert';
import 'package:http/http.dart' as http;

class ExtraCurrency {



  Future<Map<String, double>> fetchExchangeRates(
      String baseCurrencyCode) async {
    var url = Uri.parse('https://open.er-api.com/v6/latest/$baseCurrencyCode');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return Map.from(data['rates'])
          .map((currencyCode, rate) => MapEntry(currencyCode, rate.toDouble()));
    } else {
      throw Exception('Failed to fetch exchange rates');
    }
  }


}
