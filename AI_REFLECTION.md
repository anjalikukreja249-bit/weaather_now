# AI Reflection Note — Where the AI Got It Wrong

## Overview

This note documents the concrete mistakes made by the AI assistant (Claude / Cursor) during development of WeatherNow, how each was caught, and what was changed.

---

## 1. Units hardcoded in `DioClient` — not passable per-request

**What the AI generated:**

```dart
// DioClient constructor
queryParameters: {
  'appid': AppConstants.apiKey,
  'units': 'metric',   // ← baked in at construction time
},
```

**Why it's wrong:**  
The assignment requires a °C/°F toggle that updates all screens immediately. Baking `'units': 'metric'` into the `BaseOptions` constructor means every request always sends metric regardless of the user's setting. Switching to imperial in Settings would have had zero effect on the API calls.

**How I caught it:**  
When I wired up the `toggleUnit()` method in `SettingsNotifier` and tried to call `refreshWithUnits('imperial')`, I noticed the Dio requests were still returning Celsius values. Checking `DioClient`, the hardcoded `queryParameters` in `BaseOptions` was the culprit — it can't be overridden per-request without explicitly merging.

**What I changed:**  
Removed `'units'` from `BaseOptions.queryParameters`. Added a `units` named parameter to `DioClient.get()` that is merged into each request's query parameters:

```dart
Future<Response<T>> get<T>(
  String path, {
  Map<String, dynamic>? queryParameters,
  String units = 'metric',   // ← now per-request
}) async {
  final params = <String, dynamic>{'units': units, ...?queryParameters};
  return await _dio.get<T>(path, queryParameters: params);
}
```

---

## 2. `DioClient.get()` had a non-`Never` error handler — analyzer warning

**What the AI generated:**

```dart
Future<Response<T>> get<T>(...) async {
  try {
    return await _dio.get<T>(...);
  } on DioException catch (e) {
    _handleDioError(e);   // ← void return, analyzer sees missing return
  }
}

void _handleDioError(DioException e) { throw ...; }
```

**Why it's wrong:**  
`_handleDioError` always throws, but its return type is `void`. Dart's flow analysis cannot see that the `catch` block never completes normally, so the analyzer reports a "missing return" warning on `get()`. In strict analysis mode this becomes an error.

**How I caught it:**  
Running `flutter analyze` immediately flagged: *"The body might complete normally, causing 'null' to be returned, but the return type, 'Response\<T\>', is a potentially non-nullable type."*

**What I changed:**  
Changed `_handleDioError`'s return type to `Never`:

```dart
Never _handleDioError(DioException e) { throw ...; }
```

Dart now understands the call site can never return normally, silencing the warning correctly.

---

## 3. `SharedPreferences` not initialized before `SettingsNotifier.build()` ran

**What the AI generated:**

```dart
// settings_provider.dart
class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => const AppSettings();  // no persistence
}
```

And in `weather_provider.dart`:

```dart
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in ProviderScope...');
});
```

But `main.dart` never called `SharedPreferences.getInstance()` or provided the override.

**Why it's wrong:**  
`SettingsNotifier.build()` tried to read `settingsPrefsProvider` which threw `UnimplementedError` at runtime. The app crashed on startup with an unhandled exception before any widget rendered.

**How I caught it:**  
First cold run on device threw `UnimplementedError: Override settingsPrefsProvider in ProviderScope.` in the Flutter error overlay.

**What I changed:**  
Added `SharedPreferences.getInstance()` to `main()` (which is `async`) and passed the result as a `ProviderScope` override before `runApp`:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        settingsPrefsProvider.overrideWithValue(prefs),
      ],
      child: const WeatherNowApp(),
    ),
  );
}
```

---

## 4. `ForecastDetailScreen` showed all 40 raw slots instead of a per-day breakdown

**What the AI generated:**

The screen read `forecastProvider` and rendered all 40 three-hour slots as a flat `ListView`, ignoring which day the user tapped.

**Why it's wrong:**  
The spec says: *"Tap a day in the forecast strip to open it. Show whatever breakdown you have for that day from the 3-hour data — morning/afternoon/evening is fine."* The AI-generated screen had no concept of a selected day and no route arguments.

**How I caught it:**  
Manually tapping any chip in the `ForecastStrip` navigated to the detail screen but showed all 40 entries for all 5 days — clearly wrong and confusing.

**What I changed:**  
- Added `ForecastDetailArgs` (a plain Dart class) carrying `dateKey` and the list of `ForecastDay` slots for that day.
- Made each `_ForecastChip` call `Navigator.pushNamed('/forecast', arguments: ForecastDetailArgs(...))`.
- Rewrote `ForecastDetailScreen` to read `ModalRoute.of(context)?.settings.arguments` and render only the slots for the selected day, labelled Morning / Afternoon / Evening / Night.

---

## Summary Table

| # | Issue | Caught by | Fix |
|---|---|---|---|
| 1 | Units hardcoded in `DioClient` — toggle had no effect | Manual testing | Pass `units` per-request |
| 2 | `_handleDioError` return type `void` — analyzer warning | `flutter analyze` | Change return type to `Never` |
| 3 | `SharedPreferences` never initialized — crash on startup | First device run | `await SharedPreferences.getInstance()` in `main()` + ProviderScope override |
| 4 | Forecast detail showed all 40 slots, not per-day | Manual testing | Route arguments + `ForecastDetailArgs` |
