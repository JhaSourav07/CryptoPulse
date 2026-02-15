class CoinModel {
  final String id;
  final String symbol;
  final String name;
  final String image;
  final double currentPrice;
  final double priceChangePercentage24h;

  CoinModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.priceChangePercentage24h,
  });

  factory CoinModel.fromJson(Map<String, dynamic> json) {
    // 🛡️ Helper to safely convert API values to double, handling NULLs
    double safeDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is int) return val.toDouble();
      if (val is double) return val;
      return 0.0; // Fallback for unexpected types
    }

    return CoinModel(
      id: json['id']?.toString() ?? 'unknown',
      symbol: json['symbol']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      currentPrice: safeDouble(json['current_price']),
      priceChangePercentage24h: safeDouble(json['price_change_percentage_24h']),
    );
  }
}