import 'dart:async';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/coin_model.dart';

class CryptoController extends GetxController with StateMixin<List<CoinModel>> {
  final ApiService _apiService = ApiService();
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    // 1. Initial Load (Shows full loading spinner)
    fetchCoins(isInitialLoad: true);
    
    // 2. Start Auto-Refresh Timer (Every 60 seconds)
    // We use 60s to stay within CoinGecko's free tier rate limits
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      fetchCoins(isInitialLoad: false);
    });
  }

  @override
  void onClose() {
    // 3. Prevent memory leaks by cancelling timer
    _timer?.cancel();
    super.onClose();
  }

  Future<void> fetchCoins({bool isInitialLoad = false}) async {
    if (isInitialLoad) {
      change(null, status: RxStatus.loading());
    }

    try {
      final coins = await _apiService.fetchTopCoins();
      
      if (coins.isEmpty) {
        change([], status: RxStatus.empty());
      } else {
        // Success: Update state seamlessly
        change(coins, status: RxStatus.success());
      }
    } catch (e) {
      // Only show error screen on initial load.
      // If a background update fails, keep showing old data.
      if (isInitialLoad) {
        change(null, status: RxStatus.error(e.toString()));
      } else {
        print("Background update failed: $e"); 
      }
    }
  }

  // Wrapper for manual Pull-to-Refresh
  Future<void> refreshData() async {
    await fetchCoins(isInitialLoad: false);
  }
}