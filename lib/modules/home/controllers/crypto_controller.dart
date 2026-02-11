import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/coin_model.dart';

class CryptoController extends GetxController with StateMixin<List<CoinModel>> {
  final ApiService _apiService = ApiService();
  final _storage = GetStorage();
  Timer? _timer;
  
  final lastUpdated = "".obs;
  
  // 💖 Favorites List (Stores Coin IDs like 'bitcoin', 'ethereum')
  final RxList<String> favoriteIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    // 1. Load favorites from disk
    if (_storage.hasData('favorites')) {
      favoriteIds.assignAll(List<String>.from(_storage.read('favorites')));
    }

    // 2. Start fetching data
    fetchCoins(isInitialLoad: true);
    
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchCoins(isInitialLoad: false);
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> fetchCoins({bool isInitialLoad = false}) async {
    if (isInitialLoad) change(null, status: RxStatus.loading());

    try {
      final coins = await _apiService.fetchTopCoins();
      final now = DateTime.now();
      lastUpdated.value = "${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}";
      
      if (coins.isEmpty) {
        change([], status: RxStatus.empty());
      } else {
        change(coins, status: RxStatus.success());
      }
    } catch (e) {
      if (isInitialLoad) change(null, status: RxStatus.error(e.toString()));
    }
  }

  // 🕹️ Actions
  void toggleFavorite(String coinId) {
    if (favoriteIds.contains(coinId)) {
      favoriteIds.remove(coinId);
    } else {
      favoriteIds.add(coinId);
    }
    // Save to disk
    _storage.write('favorites', favoriteIds.toList());
  }

  bool isFavorite(String coinId) => favoriteIds.contains(coinId);

  // Helper to get only favorite coin objects from the main list
  List<CoinModel> get favoriteCoins {
    if (state == null) return [];
    return state!.where((coin) => favoriteIds.contains(coin.id)).toList();
  }
}