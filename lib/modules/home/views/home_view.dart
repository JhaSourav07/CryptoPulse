import 'package:cryptopulse/modules/home/views/detail_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/crypto_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/coin_model.dart';

class HomeView extends GetView<CryptoController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text("CRYPTO PULSE"),
            Obx(() => Text(
              controller.lastUpdated.value.isEmpty 
                  ? "Connecting..." 
                  : "Last updated: ${controller.lastUpdated.value}",
              style: const TextStyle(
                fontSize: 12, 
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400
              ),
            )),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.accent),
            onPressed: () => controller.fetchCoins(isInitialLoad: true),
          )
        ],
      ),
      body: controller.obx(
        (state) => RefreshIndicator(
          onRefresh: () async => controller.fetchCoins(isInitialLoad: false),
          color: AppColors.accent,
          backgroundColor: AppColors.surface,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: state?.length ?? 0,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final coin = state![index];
              return GestureDetector(
                // 🚀 Add Navigation Here
                onTap: () => Get.to(() => const DetailView(), arguments: coin),
                child: _CoinTile(coin: coin),
              );
            },
          ),
        ),
        onLoading: const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        onError: (error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                error ?? "Connection Failed",
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.fetchCoins(isInitialLoad: true),
                child: const Text("Retry"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _CoinTile extends StatelessWidget {
  final CoinModel coin;

  const _CoinTile({required this.coin});

  @override
  Widget build(BuildContext context) {
    final bool isPositive = coin.priceChangePercentage24h >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage: NetworkImage(coin.image),
            radius: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coin.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Text(
                  coin.symbol.toUpperCase(),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "\$${coin.currentPrice.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: isPositive ? AppColors.accent : AppColors.error,
                    size: 20,
                  ),
                  Text(
                    "${coin.priceChangePercentage24h.toStringAsFixed(2)}%",
                    style: TextStyle(
                      color: isPositive ? AppColors.accent : AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}