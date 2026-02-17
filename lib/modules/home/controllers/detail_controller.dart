import 'package:cryptopulse/modules/home/controllers/crypto_controller.dart';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/coin_model.dart';

class DetailController extends GetxController with StateMixin<List<List<double>>> {
  final ApiService _apiService = ApiService();
  late CoinModel coin;

  @override
  void onInit() {
    super.onInit();
    // Get arguments passed from HomeView
    coin = Get.arguments as CoinModel;
    fetchChartData();
  }

  Future<void> fetchChartData() async {
    change(null, status: RxStatus.loading());
    try {
      final history = await _apiService.fetchCoinHistory(coin.id, Get.find<CryptoController>().selectedCurrency.value);
      change(history, status: RxStatus.success());
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }
}