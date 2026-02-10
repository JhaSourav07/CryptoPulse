import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/coin_model.dart';

class ApiService {
  static const String _baseUrl = "https://api.coingecko.com/api/v3";

  Future<List<CoinModel>> fetchTopCoins() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&page=1&sparkline=false"),
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

  /// NEW: Fetch 7-day price history for a specific coin
  /// Returns a list of [timestamp, price]
  Future<List<List<double>>> fetchCoinHistory(String coinId) async {
    try {
      final url = "$_baseUrl/coins/$coinId/market_chart?vs_currency=usd&days=7&interval=daily";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> prices = data['prices'];
        
        // Convert to List<List<double>>
        return prices.map((item) {
          return [
            (item[0] as num).toDouble(), // Timestamp
            (item[1] as num).toDouble(), // Price
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