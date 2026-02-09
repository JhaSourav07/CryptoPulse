import 'dart:async';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/coin_model.dart';

class CryptoController extends GetxController with StateMixin<List<CoinModel>> {
  final ApiService _apiService = ApiService();
  Timer? _timer;
  
  // Observable to show the user when data was last fetched
  final lastUpdated = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchCoins(isInitialLoad: true);
    
    // REDUCED TIMER: 30 seconds for better feedback
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      print("⏰ Auto-refresh triggered at ${DateTime.now()}");
      fetchCoins(isInitialLoad: false);
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> fetchCoins({bool isInitialLoad = false}) async {
    if (isInitialLoad) {
      change(null, status: RxStatus.loading());
    }

    try {
      print("🔄 Fetching data from API...");
      final coins = await _apiService.fetchTopCoins();
      
      // Update timestamp
      final now = DateTime.now();
      lastUpdated.value = "${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}:${now.second.toString().padLeft(2,'0')}";

      if (coins.isEmpty) {
        change([], status: RxStatus.empty());
      } else {
        // Force update even if data looks similar
        change(coins, status: RxStatus.success());
      }
      print("✅ Data updated successfully");
    } catch (e) {
      print("❌ Error fetching data: $e");
      if (isInitialLoad) {
        change(null, status: RxStatus.error(e.toString()));
      }
    }
  }
}