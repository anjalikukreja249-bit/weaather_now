# WeatherNow 🌤️

A Flutter weather app built with Clean Architecture, Riverpod, and the OpenWeatherMap API.

## Features
- 🔍 **City search** — type a city, see current weather (icon, temp, description, humidity, wind)
- 📅 **5-day forecast** — horizontal strip on home; tap any day for 3-hour morning/afternoon/evening breakdown
- ⭐ **Favourites** — star any city; swipe left or tap the trash icon to remove; persisted across restarts
- 📡 **Offline mode** — cached data shown automatically with "updated Xh ago" staleness label
- 🌡️ **°C / °F toggle** — flips all screens instantly; persisted across restarts
- 🌙 **Dark / Light theme** — persisted across restarts
- 🔄 **Last city restored** — reopening the app shows the last city you searched

## Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0.0
- A free [OpenWeatherMap](https://home.openweathermap.org/users/sign_up) API key

### Setup
```bash
# 1. Clone
git clone https://github.com/your-org/weather_now.git
cd weather_now

# 2. Add your API key (never commit this file — it is in .gitignore)
echo "OPENWEATHER_API_KEY=your_key_here" > .env

# 3. Install dependencies
flutter pub get

# 4. Run
flutter run
```

### Running tests
```bash
# Generate mocks first (only needed once or after model changes)
flutter pub run build_runner build --delete-conflicting-outputs

# Run all tests
flutter test
```

## Project Structure
```
lib/
├── core/
│   ├── constants/     # AppConstants (API URL, cache keys)
│   ├── errors/        # Typed exceptions (Network, Server, City, Cache, Auth)
│   ├── network/       # DioClient with per-request unit param
│   └── utils/         # ConnectivityHelper, WeatherDateUtils
├── data/
│   ├── models/        # WeatherModel, ForecastModel, CityCacheModel (fromJson/toJson)
│   ├── datasources/
│   │   ├── remote/    # WeatherRemoteDataSourceImpl
│   │   └── local/     # WeatherLocalDataSourceImpl (SharedPreferences)
│   └── repositories/  # WeatherRepositoryImpl (offline fallback, last city)
├── domain/
│   ├── entities/      # Weather, ForecastDay (pure Dart — no Flutter/JSON)
│   └── repositories/  # WeatherRepository abstract interface
├── presentation/
│   ├── providers/     # weatherProvider, forecastProvider, favoritesProvider, settingsProvider
│   ├── screens/       # Home, ForecastDetail, Favorites, Settings
│   └── widgets/       # WeatherCard, ForecastStrip, CachedWeatherIcon, OfflineBanner…
├── app.dart           # MaterialApp + named routes
└── main.dart          # Entry point: dotenv, SharedPreferences, ProviderScope
```

## Architecture
Clean Architecture with unidirectional dependency flow:
```
presentation → domain ← data
```
- **Domain entities** (`Weather`, `ForecastDay`) are pure Dart — no Flutter imports, no JSON
- **Data models** extend entities and add `fromJson` / `toJson`
- **Repository impl** decides remote vs cache based on connectivity
- **Providers** are the only bridge between presentation and domain

## Key Design Decisions

| Decision | Rationale |
|---|---|
| Riverpod `AsyncNotifier` for weather | Gives `AsyncValue` (loading/data/error) for free, no boilerplate |
| Units passed per-request to Dio | Baking units into `BaseOptions` would ignore the toggle |
| `SharedPreferences` overridden in `ProviderScope` | Allows the same instance to be injected in tests without a plugin |
| `cached_network_image` for icons | Prevents re-downloading the same icon on every scroll / screen change |
| `ForecastDetailArgs` route argument | Avoids a second network call when tapping a day; reuses in-memory data |
| `Never` return type on `_handleDioError` | Fixes analyzer "missing return" warning — see `AI_REFLECTION.md` |

## What I'd do with more time
- Add `go_router` for type-safe routes (replace `Navigator.pushNamed`)
- Hive or SQLite for structured local storage instead of JSON-in-SharedPreferences
- Widget tests for `WeatherCard` and `ForecastStrip` using `flutter_test`
- GitHub Actions CI pipeline running `flutter analyze` + `flutter test`
- Geolocation support (auto-detect current city on first open)

## Dependencies
| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `dio` | HTTP client |
| `flutter_dotenv` | Environment variables |
| `connectivity_plus` | Network status stream |
| `shared_preferences` | Local cache + settings persistence |
| `cached_network_image` | Disk-cached weather icons |
| `intl` | Date formatting |
| `mockito` + `build_runner` | Test mocks |

## Security
- API key lives in `.env` only — never in source code
- `.env` is in `.gitignore`
- `pubspec.yaml` lists `.env` as a Flutter asset so `flutter_dotenv` can load it at runtime
- No secrets are logged (Dio `LogInterceptor` has `requestBody: false`)

## AI Reflection
See [`AI_REFLECTION.md`](./AI_REFLECTION.md) for a documented account of where the AI got things wrong, how each issue was caught, and what was changed.

## License
MIT
