import '../../core/errors/exceptions.dart';
import '../../core/utils/connectivity_helper.dart';
import '../../domain/entities/weather.dart';
import '../../domain/entities/forecast_day.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/local/weather_local_datasource.dart';
import '../datasources/remote/weather_remote_datasource.dart';
import '../models/forecast_model.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  const WeatherRepositoryImpl({
    required this.remote,
    required this.local,
    required this.connectivity,
  });

  final WeatherRemoteDataSource remote;
  final WeatherLocalDataSource local;
  final ConnectivityHelper connectivity;

  @override
  Future<Weather> getCurrentWeather(
    String city, {
    String units = 'metric',
  }) async {
    final isOnline = await connectivity.isConnected;
    if (!isOnline) {
      final cached = await local.getCachedWeather(city);
      if (cached != null) return cached;
      throw const NetworkException();
    }
    final model = await remote.getCurrentWeather(city, units: units);
    await local.cacheWeather(model);
    return model;
  }

  @override
  Future<List<ForecastDay>> getForecast(
    String city, {
    String units = 'metric',
  }) async {
    final isOnline = await connectivity.isConnected;
    if (!isOnline) {
      // Offline: return cached forecast (may be empty)
      final cached = await local.getCachedForecast(city);
      if (cached.isNotEmpty) return cached;
      throw const NetworkException();
    }
    final models = await remote.getForecast(city, units: units);
    // Cache the raw ForecastModel list
    await local.cacheForecast(
      city,
      models.whereType<ForecastModel>().toList(),
    );
    return models;
  }

  @override
  Future<List<String>> getFavoriteCities() => local.getFavoriteCities();

  @override
  Future<void> saveFavoriteCities(List<String> cities) =>
      local.saveFavoriteCities(cities);

  @override
  Future<String?> getLastCity() => local.getLastCity();

  @override
  Future<void> saveLastCity(String city) => local.saveLastCity(city);
}
