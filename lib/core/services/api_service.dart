import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/coin_model.dart';

class ApiService {
  static const String _baseUrl = "https://api.coingecko.com/api/v3";

  Future<List<CoinModel>> fetchTopCoins() async {
    final response = await http.get(Uri.parse(
        "$_baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&page=1"));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => CoinModel.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load crypto data");
    }
  }
}