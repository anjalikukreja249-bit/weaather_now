# CLAUDE.md — WeatherNow Project Guidelines

## Project Overview
WeatherNow is a Flutter weather app using Clean Architecture with Riverpod for state management and Dio for networking.

## Architecture
This project follows **Clean Architecture** with three layers:
- **`lib/data/`** — Models, remote/local datasources, repository implementations
- **`lib/domain/`** — Entities, abstract repository contracts (no Flutter/Dart:io dependencies)
- **`lib/presentation/`** — Riverpod providers, screens, widgets

Dependency direction: `presentation → domain ← data`

## Key Conventions

### Naming
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Providers: suffix with `Provider` (e.g. `weatherProvider`)
- Models: suffix with `Model` (e.g. `WeatherModel`)
- Entities: no suffix (e.g. `Weather`, `ForecastDay`)

### State Management
- Use **Riverpod** (`flutter_riverpod`) for all state
- Providers live in `lib/presentation/providers/`
- Prefer `AsyncNotifierProvider` for async data, `NotifierProvider` for sync state

### Networking
- All HTTP calls go through `DioClient` in `lib/core/network/dio_client.dart`
- API key is loaded from `.env` via `flutter_dotenv` — never hardcode keys
- Remote datasource handles raw API responses; repository maps to domain entities

### Error Handling
- Throw typed exceptions from `lib/core/errors/exceptions.dart`
- Use `Result` / `Either` pattern or `AsyncValue` (Riverpod) at the presentation layer

### Offline Support
- `ConnectivityHelper` checks network state before API calls
- Local datasource caches last-known weather using `shared_preferences` or `hive`
- `OfflineBanner` widget is shown when device is offline

## Environment Setup
```bash
# 1. Copy env template and add your key
cp .env.example .env   # edit OPENWEATHER_API_KEY

# 2. Install dependencies
flutter pub get

# 3. Run
flutter run
```

## DO / DON'T
- ✅ Keep domain entities free of `fromJson` / `toJson` — that belongs in models
- ✅ Write unit tests for providers and repository implementations
- ❌ Never import `package:flutter` inside `lib/domain/`
- ❌ Never call the API directly from a widget or screen
- ❌ Never commit `.env`
