import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/dio_client.dart';
import '../../core/utils/connectivity_helper.dart';
import '../../data/datasources/local/weather_local_datasource.dart';
import '../../data/datasources/remote/weather_remote_datasource.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/entities/forecast_day.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import 'settings_provider.dart';

// ── Infrastructure providers ──────────────────────────────────────────────────

/// Must be overridden in main.dart ProviderScope with the real instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'Override sharedPreferencesProvider in ProviderScope.',
  );
});

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final connectivityHelperProvider = Provider<ConnectivityHelper>(
  (ref) => ConnectivityHelper(Connectivity()),
);

final weatherRemoteDataSourceProvider = Provider<WeatherRemoteDataSource>(
  (ref) => WeatherRemoteDataSourceImpl(ref.watch(dioClientProvider)),
);

final weatherLocalDataSourceProvider = Provider<WeatherLocalDataSource>(
  (ref) => WeatherLocalDataSourceImpl(ref.watch(sharedPreferencesProvider)),
);

final weatherRepositoryProvider = Provider<WeatherRepository>(
  (ref) => WeatherRepositoryImpl(
    remote: ref.watch(weatherRemoteDataSourceProvider),
    local: ref.watch(weatherLocalDataSourceProvider),
    connectivity: ref.watch(connectivityHelperProvider),
  ),
);

// ── Current weather ───────────────────────────────────────────────────────────

class WeatherNotifier extends AsyncNotifier<Weather?> {
  @override
  Future<Weather?> build() async {
    // Restore last searched city on startup
    final lastCity = await ref.read(weatherRepositoryProvider).getLastCity();
    if (lastCity == null) return null;
    final units = ref.read(settingsProvider).apiUnits;
    return ref
        .read(weatherRepositoryProvider)
        .getCurrentWeather(lastCity, units: units);
  }

  Future<void> fetchWeather(String city) async {
    state = const AsyncLoading();
    final units = ref.read(settingsProvider).apiUnits;
    state = await AsyncValue.guard(() async {
      final weather = await ref
          .read(weatherRepositoryProvider)
          .getCurrentWeather(city, units: units);
      await ref.read(weatherRepositoryProvider).saveLastCity(city);
      return weather;
    });
  }

  /// Re-fetches the current city with new units after the unit toggle changes.
  Future<void> refreshWithUnits(String units) async {
    final city = state.valueOrNull?.cityName;
    if (city == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(weatherRepositoryProvider)
          .getCurrentWeather(city, units: units),
    );
  }
}

final weatherProvider = AsyncNotifierProvider<WeatherNotifier, Weather?>(
  WeatherNotifier.new,
);

// ── Forecast ──────────────────────────────────────────────────────────────────

class ForecastNotifier extends AsyncNotifier<List<ForecastDay>> {
  @override
  Future<List<ForecastDay>> build() async => [];

  Future<void> fetchForecast(String city) async {
    state = const AsyncLoading();
    final units = ref.read(settingsProvider).apiUnits;
    state = await AsyncValue.guard(
      () => ref.read(weatherRepositoryProvider).getForecast(city, units: units),
    );
  }

  Future<void> refreshWithUnits(String units) async {
    final city = ref.read(weatherProvider).valueOrNull?.cityName;
    if (city == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(weatherRepositoryProvider).getForecast(city, units: units),
    );
  }
}

final forecastProvider =
    AsyncNotifierProvider<ForecastNotifier, List<ForecastDay>>(
      ForecastNotifier.new,
    );
