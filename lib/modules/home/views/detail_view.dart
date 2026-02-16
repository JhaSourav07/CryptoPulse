import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/detail_controller.dart';
import '../../home/controllers/crypto_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/coin_model.dart';

class DetailView extends StatelessWidget {
  const DetailView({super.key});

  String _formatDate(DateTime date) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${months[date.month - 1]} ${date.day}";
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DetailController());
    final homeController = Get.find<CryptoController>();
    
    final coin = controller.coin;
    final isPositive = coin.priceChangePercentage24h >= 0;
    final themeColor = isPositive ? AppColors.accent : AppColors.error;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(coin.name.toUpperCase()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Obx(() {
            final isFav = homeController.isFavorite(coin.id);
            return IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? AppColors.error : Colors.white,
              ),
              onPressed: () => homeController.toggleFavorite(coin.id),
            );
          })
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // Date
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(bottom: 20),
              child: Text(
                _formatDate(DateTime.now()), 
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.2),
              ),
            ),
            
            // Header Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("\$${coin.currentPrice.toStringAsFixed(2)}", style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.0)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: themeColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          Icon(isPositive ? Icons.trending_up : Icons.trending_down, color: themeColor, size: 16),
                          const SizedBox(width: 4),
                          Text("${coin.priceChangePercentage24h.toStringAsFixed(2)}%", style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
                Hero(tag: coin.id, child: Image.network(coin.image, height: 64, width: 64)),
              ],
            ),
            
            const SizedBox(height: 30),

            // 💰 NEW: My Position Card
            _buildPositionCard(context, homeController, coin),

            const SizedBox(height: 30),
            
            // Chart
            Container(
              height: 300,
              width: double.infinity,
              padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))]),
              child: controller.obx(
                (history) {
                  if (history == null || history.isEmpty) return const SizedBox();
                  final prices = history.map((e) => e[1]).toList();
                  final double minPrice = prices.reduce(min);
                  final double maxPrice = prices.reduce(max);
                  final double interval = (maxPrice - minPrice) / 4;

                  return LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: interval, getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1)),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                          return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text("${date.day}/${date.month}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)));
                        }, interval: 86400000 * 2)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: history.map((point) => FlSpot(point[0], point[1])).toList(),
                          isCurved: true, color: themeColor, barWidth: 3, isStrokeCapRound: true, dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [themeColor.withOpacity(0.3), themeColor.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                        ),
                      ],
                      lineTouchData: LineTouchData(touchTooltipData: LineTouchTooltipData(tooltipBgColor: AppColors.surface, getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                          return LineTooltipItem("${_formatDate(date)}\n", const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold), children: [TextSpan(text: "\$${spot.y.toStringAsFixed(2)}", style: TextStyle(color: themeColor, fontSize: 14, fontWeight: FontWeight.bold))]);
                        }).toList();
                      })),
                    ),
                  );
                },
                onLoading: const Center(child: CircularProgressIndicator(color: AppColors.accent)),
                onError: (err) => Center(child: Text("Chart unavailable", style: TextStyle(color: AppColors.error))),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Stats
            controller.obx((history) {
               if (history == null || history.isEmpty) return const SizedBox();
               final prices = history.map((e) => e[1]).toList();
               return Row(children: [
                   Expanded(child: _StatCard(label: "7d Low", value: "\$${prices.reduce(min).toStringAsFixed(2)}", icon: Icons.arrow_downward, color: AppColors.error)),
                   const SizedBox(width: 16),
                   Expanded(child: _StatCard(label: "7d High", value: "\$${prices.reduce(max).toStringAsFixed(2)}", icon: Icons.arrow_upward, color: AppColors.accent)),
               ]);
            }),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // 🏦 Position Card Widget
  Widget _buildPositionCard(BuildContext context, CryptoController homeCtrl, CoinModel coin) {
    return Obx(() {
      final amount = homeCtrl.getHoldingAmount(coin.id);
      final value = amount * coin.currentPrice;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.surface, AppColors.surface.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("My Position", style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                GestureDetector(
                  onTap: () => _showEditDialog(context, homeCtrl, coin, amount),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Text("Edit", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "\$${value.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$amount ${coin.symbol.toUpperCase()}",
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
                Icon(Icons.account_balance_wallet, color: Colors.white.withOpacity(0.1), size: 40),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ✏️ Edit Dialog
  void _showEditDialog(BuildContext context, CryptoController ctrl, CoinModel coin, double currentAmount) {
    final textCtrl = TextEditingController(text: currentAmount > 0 ? currentAmount.toString() : "");
    
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Update ${coin.name}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text("How many coins do you hold?", style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              TextField(
                controller: textCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.accent),
                decoration: InputDecoration(
                  hintText: "0.0",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                  border: InputBorder.none,
                  suffixText: coin.symbol.toUpperCase(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text("Cancel", style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.black),
                    onPressed: () {
                      final val = double.tryParse(textCtrl.text.replaceAll(',', '.')) ?? 0.0;
                      ctrl.updateHolding(coin.id, val);
                      Get.back();
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, size: 16, color: color), const SizedBox(width: 8), Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))]),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ]),
    );
  }
}