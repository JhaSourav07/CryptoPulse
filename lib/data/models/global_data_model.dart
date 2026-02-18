class GlobalDataModel {
  final double totalMarketCap;
  final double totalVolume;
  final double btcDominance;
  final double marketCapChangePercentage24h;

  GlobalDataModel({
    required this.totalMarketCap,
    required this.totalVolume,
    required this.btcDominance,
    required this.marketCapChangePercentage24h,
  });

  factory GlobalDataModel.fromJson(Map<String, dynamic> json, String currency) {
    final data = json['data'];
    
    // Helper to safely extract dynamic currency values
    double getValue(Map<String, dynamic> map, String key) {
      if (map[key] == null) return 0.0;
      return (map[key] as num).toDouble();
    }

    return GlobalDataModel(
      totalMarketCap: getValue(data['total_market_cap'], currency),
      totalVolume: getValue(data['total_volume'], currency),
      btcDominance: getValue(data['market_cap_percentage'], 'btc'),
      marketCapChangePercentage24h: (data['market_cap_change_percentage_24h_usd'] as num?)?.toDouble() ?? 0.0,
    );
  }
}