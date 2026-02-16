package com.example.cryptopulse // Check your package name!

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class CryptoWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // 1. Get Data
                val name = widgetData.getString("coin_name", "Select Coin")
                val symbol = widgetData.getString("coin_symbol", "--")
                val price = widgetData.getString("coin_price", "--")
                val change = widgetData.getString("coin_change", "--")
                val isPositive = widgetData.getBoolean("coin_change_positive", true)
                
                val showHoldings = widgetData.getBoolean("show_holdings", false)
                val holdingsValue = widgetData.getString("holdings_value", "$0.00")

                // 2. Set Basic Texts
                setTextViewText(R.id.coin_name, name)
                setTextViewText(R.id.coin_symbol, symbol)
                setTextViewText(R.id.coin_price, price)
                setTextViewText(R.id.coin_change, change)

                // 3. Set Dynamic Color (Green/Red)
                val color = if (isPositive) Color.parseColor("#00E676") else Color.parseColor("#CF6679")
                setTextColor(R.id.coin_change, color)

                // 4. Handle Holdings Visibility
                if (showHoldings) {
                    setViewVisibility(R.id.holdings_container, View.VISIBLE)
                    setTextViewText(R.id.holdings_value, holdingsValue)
                } else {
                    setViewVisibility(R.id.holdings_container, View.GONE)
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
