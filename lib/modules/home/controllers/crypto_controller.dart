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
  final RxMap<String, double> holdings = <String, double>{}.obs;
  final searchText = "".obs;

  // 🌍 Currency State
  final selectedCurrency = "usd".obs;
  final currencySymbol = "\$".obs;

  @override
  void onInit() {
    super.onInit();
    // Load Settings
    if (_storage.hasData('favorites')) {
      favoriteIds.assignAll(List<String>.from(_storage.read('favorites')));
    }
    if (_storage.hasData('holdings')) {
      final storedHoldings = _storage.read('holdings') as Map<dynamic, dynamic>;
      holdings.assignAll(storedHoldings.map((key, value) => MapEntry(key.toString(), value as double)));
    }
    // Load Saved Currency
    if (_storage.hasData('currency')) {
      selectedCurrency.value = _storage.read('currency');
      _updateSymbol();
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
      // Pass the selected currency to the API
      final coins = await _apiService.fetchTopCoins(selectedCurrency.value);
      
      if (isClosed) return;

      final now = DateTime.now();
      lastUpdated.value = "${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}";
      
      if (coins.isEmpty) {
        change([], status: RxStatus.empty());
      } else {
        change(coins, status: RxStatus.success());
      }
    } catch (e) {
      if (isClosed) return;
      if (isInitialLoad) change(null, status: RxStatus.error(e.toString()));
    }
  }

  // 💱 Change Currency
  void changeCurrency(String code) {
    selectedCurrency.value = code;
    _updateSymbol();
    _storage.write('currency', code);
    fetchCoins(isInitialLoad: true); // Reload data with new currency
  }

  void _updateSymbol() {
    switch (selectedCurrency.value) {
      case 'inr': currencySymbol.value = "₹"; break;
      case 'eur': currencySymbol.value = "€"; break;
      case 'gbp': currencySymbol.value = "£"; break;
      default: currencySymbol.value = "\$";
    }
  }

  // --- Logic for Favorites, Search, Portfolio ---
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

  List<CoinModel> filterCoins(List<CoinModel> sourceList) {
    if (searchText.value.isEmpty) return sourceList;
    return sourceList.where((coin) {
      return coin.name.toLowerCase().contains(searchText.value.toLowerCase()) ||
             coin.symbol.toLowerCase().contains(searchText.value.toLowerCase());
    }).toList();
  }

  void updateHolding(String coinId, double amount) {
    if (amount <= 0) {
      holdings.remove(coinId);
    } else {
      holdings[coinId] = amount;
    }
    _storage.write('holdings', holdings);
  }

  double getHoldingAmount(String coinId) => holdings[coinId] ?? 0.0;
  
  double get totalPortfolioValue {
    if (state == null) return 0.0;
    double total = 0.0;
    holdings.forEach((id, amount) {
      final coin = state!.firstWhereOrNull((c) => c.id == id);
      if (coin != null) {
        total += coin.currentPrice * amount;
      }
    });
    return total;
  }
}