import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/coin_model.dart';

class ApiService {
  static const String _baseUrl = "https://api.coingecko.com/api/v3";

  // 🌍 Now accepts a currency code (default: usd)
  Future<List<CoinModel>> fetchTopCoins(String currency) async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/coins/markets?vs_currency=$currency&order=market_cap_desc&per_page=50&page=1&sparkline=false"),
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => CoinModel.fromJson(item)).toList();
      } else {
        throw Exception("API Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to load crypto data: $e");
    }
  }

  // Fetch 7-day price history with dynamic currency
  Future<List<List<double>>> fetchCoinHistory(String coinId, String currency) async {
    try {
      final url = "$_baseUrl/coins/$coinId/market_chart?vs_currency=$currency&days=7&interval=daily";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> prices = data['prices'];
        return prices.map((item) {
          return [
            (item[0] as num).toDouble(),
            (item[1] as num).toDouble(),
          ];
        }).toList();
      } else {
        throw Exception("Failed to load chart data");
      }
    } catch (e) {
      throw Exception("Error fetching history: $e");
    }
  }
}