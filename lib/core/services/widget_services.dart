import 'package:home_widget/home_widget.dart';
import '../../data/models/coin_model.dart';

class WidgetService {
  static const String _androidWidgetName = 'CryptoWidgetProvider';
  
  /// Updates the widget with a specific coin's details
  Future<void> updateWidget({
    required CoinModel coin, 
    required double holdingsValue, 
    required bool showHoldings
  }) async {
    try {
      // 1. Save Basic Data
      await HomeWidget.saveWidgetData<String>('coin_name', coin.name);
      await HomeWidget.saveWidgetData<String>('coin_symbol', coin.symbol.toUpperCase());
      await HomeWidget.saveWidgetData<String>('coin_price', "\$${coin.currentPrice.toStringAsFixed(2)}");
      
      // 2. Save Change % (and determine color in Kotlin)
      final change = coin.priceChangePercentage24h;
      await HomeWidget.saveWidgetData<String>('coin_change', "${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%");
      await HomeWidget.saveWidgetData<bool>('coin_change_positive', change >= 0);

      // 3. Save Holdings Data
      await HomeWidget.saveWidgetData<bool>('show_holdings', showHoldings);
      await HomeWidget.saveWidgetData<String>('holdings_value', "\$${holdingsValue.toStringAsFixed(2)}");
      
      // 4. Update
      await HomeWidget.updateWidget(name: _androidWidgetName);
      print("✅ Widget Pinned: ${coin.name}");
    } catch (e) {
      print("❌ Failed to update widget: $e");
    }
  }
}