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
  final RxList<String> favoriteIds = <String>[].obs;
  
  // 🔍 Search State
  final searchText = "".obs;

  @override
  void onInit() {
    super.onInit();
    if (_storage.hasData('favorites')) {
      favoriteIds.assignAll(List<String>.from(_storage.read('favorites')));
    }

    fetchCoins(isInitialLoad: true);
    
    _timer = Timer.periodic(const Duration(seconds: 45), (timer) {
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
      
      // 🛡️ SAFETY CHECK: If controller is disposed during await, stop here.
      // This prevents "Trying to render a disposed EngineFlutterView" errors.
      if (isClosed) return;

      final now = DateTime.now();
      lastUpdated.value = "${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}";
      
      if (coins.isEmpty) {
        change([], status: RxStatus.empty());
      } else {
        change(coins, status: RxStatus.success());
      }
    } catch (e) {
      if (isClosed) return; // Safety check for errors too
      if (isInitialLoad) change(null, status: RxStatus.error(e.toString()));
    }
  }

  void toggleFavorite(String coinId) {
    if (favoriteIds.contains(coinId)) {
      favoriteIds.remove(coinId);
    } else {
      favoriteIds.add(coinId);
    }
    _storage.write('favorites', favoriteIds.toList());
  }

  bool isFavorite(String coinId) => favoriteIds.contains(coinId);

  List<CoinModel> get favoriteCoins {
    if (state == null) return [];
    return state!.where((coin) => favoriteIds.contains(coin.id)).toList();
  }

  // 🔍 Helper to filter ANY list (All or Favorites) based on search text
  List<CoinModel> filterCoins(List<CoinModel> sourceList) {
    if (searchText.value.isEmpty) return sourceList;
    return sourceList.where((coin) {
      return coin.name.toLowerCase().contains(searchText.value.toLowerCase()) ||
             coin.symbol.toLowerCase().contains(searchText.value.toLowerCase());
    }).toList();
  }
}