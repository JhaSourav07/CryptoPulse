import 'package:cryptopulse/core/services/api_service.dart';
import 'package:cryptopulse/data/models/coin_model.dart';
import 'package:get/get.dart';

class CryptoController extends GetxController with StateMixin<List<CoinModel>> {
  final ApiService _apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    fetchCoins();
  }

  Future<void> fetchCoins() async {
    change(null, status: RxStatus.loading());
    try {
      final coins = await _apiService.fetchTopCoins();
      if(coins.isEmpty){
        change([], status: RxStatus.empty());
      }
      else{
        change(coins, status: RxStatus.success());
      }
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }
}