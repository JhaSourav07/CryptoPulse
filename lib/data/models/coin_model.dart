class CoinModel {
  final String id;
  final String name;
  final String symbol;
  final String image;
  final double currentPrice;
  final double priceChangePercentage24h;

  CoinModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.image,
    required this.currentPrice,
    required this.priceChangePercentage24h,
  });

  factory CoinModel.fromJson(Map<String, dynamic> json) {
    return CoinModel(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      image: json['image'],
      currentPrice: (json['current_price'] as num).toDouble(),
      priceChangePercentage24h:
          (json['price_change_percentage_24h'] as num).toDouble(),
    );
  }
}