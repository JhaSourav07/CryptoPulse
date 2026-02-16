import 'dart:async';
import 'package:cryptopulse/core/services/widget_services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/coin_model.dart';

class CryptoController extends GetxController with StateMixin<List<CoinModel>> {
  final ApiService _apiService = ApiService();
  final WidgetService _widgetService = WidgetService(); // Instance
  final _storage = GetStorage();
  Timer? _timer;
  
  final lastUpdated = "".obs;
  final RxList<String> favoriteIds = <String>[].obs;
  final RxMap<String, double> holdings = <String, double>{}.obs;
  final searchText = "".obs;

  // 📲 Widget State
  final RxString widgetCoinId = "".obs;
  final RxBool widgetShowHoldings = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load Favorites
    if (_storage.hasData('favorites')) {
      favoriteIds.assignAll(List<String>.from(_storage.read('favorites')));
    }
    // Load Holdings
    if (_storage.hasData('holdings')) {
      final storedHoldings = _storage.read('holdings') as Map<dynamic, dynamic>;
      holdings.assignAll(storedHoldings.map((key, value) => MapEntry(key.toString(), value as double)));
    }
    // Load Widget Settings
    widgetCoinId.value = _storage.read('widget_coin_id') ?? "";
    widgetShowHoldings.value = _storage.read('widget_show_holdings') ?? false;

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
      
      if (isClosed) return;

      final now = DateTime.now();
      lastUpdated.value = "${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}";
      
      if (coins.isEmpty) {
        change([], status: RxStatus.empty());
      } else {
        change(coins, status: RxStatus.success());
        
        // 📲 AUTOMATIC WIDGET REFRESH
        // Updates the pinned widget (if one exists) with the latest API data
        _refreshWidget(coins);
      }
    } catch (e) {
      if (isClosed) return;
      if (isInitialLoad) change(null, status: RxStatus.error(e.toString()));
    }
  }

  // --- Widget Logic ---
  
  /// Called periodically to keep the home screen widget in sync with live prices
  void _refreshWidget(List<CoinModel> coins) {
    if (widgetCoinId.isEmpty) return; // No widget pinned

    final coin = coins.firstWhereOrNull((c) => c.id == widgetCoinId.value);
    if (coin != null) {
      final amount = getHoldingAmount(coin.id);
      final value = amount * coin.currentPrice;
      
      _widgetService.updateWidget(
        coin: coin,
        holdingsValue: value,
        showHoldings: widgetShowHoldings.value,
      );
    }
  }

  /// Sets the preferred coin for the home screen widget and saves to storage
  void pinWidget(String coinId, bool showHoldings) {
    widgetCoinId.value = coinId;
    widgetShowHoldings.value = showHoldings;
    _storage.write('widget_coin_id', coinId);
    _storage.write('widget_show_holdings', showHoldings);
    
    // Trigger immediate update if we have data
    if (state != null) _refreshWidget(state!);
  }

  // --- Logic for Favorites, Search, Portfolio (unchanged) ---
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