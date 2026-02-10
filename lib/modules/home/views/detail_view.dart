import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/detail_controller.dart';
import '../../../core/constants/app_colors.dart';

class DetailView extends StatelessWidget {
  const DetailView({super.key});

  // Helper for date formatting (No external dep needed)
  String _formatDate(DateTime date) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${months[date.month - 1]} ${date.day}";
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DetailController());
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
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {}, // TODO: Implement Favorites
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // 📅 1. Date & Header
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(bottom: 20),
              child: Text(
                _formatDate(DateTime.now()), // Shows "Feb 10"
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // 💎 2. Hero Section (Price & Logo)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "\$${coin.currentPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive ? Icons.trending_up : Icons.trending_down,
                            color: themeColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${coin.priceChangePercentage24h.toStringAsFixed(2)}%",
                            style: TextStyle(
                              color: themeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Hero(
                  tag: coin.id,
                  child: Image.network(coin.image, height: 64, width: 64),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // 📈 3. Interactive Chart Section
            Container(
              height: 300,
              width: double.infinity,
              padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: controller.obx(
                (history) {
                  // Calculate Min/Max for dynamic Y-Axis scaling
                  if (history == null || history.isEmpty) return const SizedBox();
                  final prices = history.map((e) => e[1]).toList();
                  final double minPrice = prices.reduce(min);
                  final double maxPrice = prices.reduce(max);
                  final double interval = (maxPrice - minPrice) / 4;

                  return LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true, 
                        drawVerticalLine: false,
                        horizontalInterval: interval,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.white.withOpacity(0.05), 
                          strokeWidth: 1
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              // Show date on X Axis
                              final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "${date.day}/${date.month}",
                                  style: const TextStyle(
                                    color: AppColors.textSecondary, 
                                    fontSize: 10
                                  ),
                                ),
                              );
                            },
                            interval: 86400000 * 2, // Show every 2 days (approx)
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: history.map((point) => FlSpot(point[0], point[1])).toList(),
                          isCurved: true,
                          color: themeColor,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                themeColor.withOpacity(0.3),
                                themeColor.withOpacity(0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                      // 🖱️ Interactive Tooltip
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: AppColors.surface,
                          tooltipRoundedRadius: 8,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                              return LineTooltipItem(
                                "${_formatDate(date)}\n",
                                const TextStyle(
                                  color: AppColors.textSecondary, 
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: "\$${spot.y.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: themeColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  );
                },
                onLoading: const Center(child: CircularProgressIndicator(color: AppColors.accent)),
                onError: (err) => Center(child: Text("Chart unavailable", style: TextStyle(color: AppColors.error))),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 📊 4. Stats Grid
            controller.obx((history) {
               if (history == null || history.isEmpty) return const SizedBox();
               final prices = history.map((e) => e[1]).toList();
               
               return Row(
                 children: [
                   Expanded(
                     child: _StatCard(
                       label: "7d Low",
                       value: "\$${prices.reduce(min).toStringAsFixed(2)}",
                       icon: Icons.arrow_downward,
                       color: AppColors.error,
                     ),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: _StatCard(
                       label: "7d High",
                       value: "\$${prices.reduce(max).toStringAsFixed(2)}",
                       icon: Icons.arrow_upward,
                       color: AppColors.accent,
                     ),
                   ),
                 ],
               );
            }),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}