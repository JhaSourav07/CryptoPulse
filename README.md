# CryptoPulse 📈

![Flutter](https://img.shields.io/badge/Flutter-3.35+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.9+-0175C2?logo=dart)
![Platform](https://img.shields.io/badge/Platform-Android%20|%20iOS%20|%20Web-lightgrey)
![License](https://img.shields.io/badge/License-MIT-green)

A sleek, real-time cryptocurrency tracking app built with Flutter. Monitor live prices, manage your portfolio, track favorites, and even pin coins to your Android home screen widget — all wrapped in a dark, neon-accented UI.

---

## Screenshots & Features

### Core Features

| Feature | Description |
|---|---|
| 📊 **Live Market Data** | Top 50 coins fetched from CoinGecko, auto-refreshed every 45 seconds |
| 🌍 **Global Market Stats** | Real-time market cap, 24h volume, and BTC dominance displayed at a glance |
| 💼 **Portfolio Tracker** | Track how many coins you hold and see your total portfolio value live |
| ❤️ **Watchlist** | Favorite coins for quick access on a dedicated tab |
| 🔍 **Search** | Filter coins by name or symbol instantly |
| 📉 **7-Day Price Chart** | Interactive line chart with 7-day high/low stats on the coin detail screen |
| 🪙 **Multi-Currency** | Switch between USD, INR, EUR, and GBP |
| 📱 **Android Home Widget** | Pin any coin to your home screen to see live price and optional holdings value |

---

## Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** GetX (`get` ^4.7.3)
- **Local Storage:** GetStorage (`get_storage` ^2.1.1)
- **Networking:** `http` ^1.6.0
- **Charts:** `fl_chart` ^0.63.0
- **Fonts:** Google Fonts (Poppins)
- **Home Widget:** `home_widget` ^0.9.0
- **API:** [CoinGecko Public API v3](https://www.coingecko.com/en/api)

---

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_colors.dart        # Dark theme color palette
│   ├── services/
│   │   ├── api_service.dart       # CoinGecko API calls
│   │   └── widget_services.dart   # Android home widget updater
│   ├── theme/
│   │   └── app_theme.dart         # App-wide dark theme
│   └── utils/
│       └── dependency_injection.dart
├── data/
│   └── models/
│       ├── coin_model.dart        # Coin data model
│       └── global_data_model.dart # Global market data model
├── modules/
│   └── home/
│       ├── controllers/
│       │   ├── crypto_controller.dart  # Main app state & logic
│       │   └── detail_controller.dart  # Chart data for detail screen
│       ├── views/
│       │   ├── home_view.dart     # Market & Watchlist tabs
│       │   └── detail_view.dart   # Coin detail + chart + position
│       └── widgets/
│           └── coin_list_tile.dart
└── main.dart
```

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.35.0`
- Dart SDK `^3.9.2`
- Android Studio / Xcode (for device/emulator builds)

### Installation

```bash
# 1. Clone the repository
git clone hhttps://github.com/JhaSourav07/CryptoPulse.git
cd CryptoPulse

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

---

## Android Home Widget Setup

The app supports an Android home screen widget built with the `home_widget` package.

The widget is defined in:
- **Layout:** `android/app/src/main/res/layout/widget_layout.xml`
- **Provider:** `android/app/src/main/kotlin/.../CryptoWidgetProvider.kt`
- **Config:** `android/app/src/main/res/xml/widget_info.xml`

To pin a widget, navigate to a coin's detail screen inside the app and use the pin option. The widget displays the coin name, symbol, current price, 24h change, and optionally your holdings value. It auto-updates every 30 minutes.

---

## API Usage

This app uses the free [CoinGecko API v3](https://www.coingecko.com/en/api). No API key is required for the endpoints used:

| Endpoint | Purpose |
|---|---|
| `/coins/markets` | Fetch top 50 coins by market cap |
| `/global` | Fetch global crypto market statistics |
| `/coins/{id}/market_chart` | Fetch 7-day price history for charts |

> **Note:** The free CoinGecko API has rate limits (~10–30 calls/minute). The app is designed to stay within these limits with its 45-second refresh cycle.

---

## Color Palette

| Name | Hex | Usage |
|---|---|---|
| Background | `#121212` | App background |
| Surface | `#1E1E1E` | Cards, tiles |
| Accent | `#00E676` | Positive changes, highlights |
| Error | `#CF6679` | Negative changes |
| Text Primary | `#FFFFFF` | Main text |
| Text Secondary | `#888888` | Labels, subtitles |

---

## Supported Platforms

| Platform | Status |
|---|---|
| Android | ✅ Full support (incl. home widget) |
| iOS | ✅ Supported |
| macOS | ✅ Supported |
| Windows | ✅ Supported |
| Linux | ✅ Supported |
| Web | ✅ Supported |

---

## License

This project is for personal/educational use. CoinGecko data is subject to their [Terms of Service](https://www.coingecko.com/en/api_terms).