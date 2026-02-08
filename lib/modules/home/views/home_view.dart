import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/crypto_controller.dart';
import '../../../core/constants/app_colors.dart';

class HomeView extends GetView<CryptoController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CryptoPulse")),
      body: controller.obx(
        (state) => RefreshIndicator(
          onRefresh: controller.fetchCoins,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state!.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final coin = state[index];
              final bool isPositive = coin.priceChangePercentage24h >= 0;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(coin.image),
                      backgroundColor: Colors.transparent,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(coin.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(coin.symbol.toUpperCase(), style: const TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("\$${coin.currentPrice.toStringAsFixed(2)}", 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          "${isPositive ? '+' : ''}${coin.priceChangePercentage24h.toStringAsFixed(2)}%",
                          style: TextStyle(
                            color: isPositive ? AppColors.accent : AppColors.error,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        onError: (error) => Center(child: Text(error ?? "An error occurred")),
      ),
    );
  }
}