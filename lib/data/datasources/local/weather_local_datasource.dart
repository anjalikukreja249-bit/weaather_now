import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/forecast_model.dart';
import '../../models/weather_model.dart';

abstract interface class WeatherLocalDataSource {
  Future<WeatherModel?> getCachedWeather(String city);
  Future<void> cacheWeather(WeatherModel weather);
  Future<List<ForecastModel>> getCachedForecast(String city);
  Future<void> cacheForecast(String city, List<ForecastModel> forecast);
  Future<List<String>> getFavoriteCities();
  Future<void> saveFavoriteCities(List<String> cities);
  Future<String?> getLastCity();
  Future<void> saveLastCity(String city);
}

class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  const WeatherLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  String _weatherKey(String city) =>
      '${AppConstants.cachedWeatherKey}_${city.toLowerCase()}';

  String _forecastKey(String city) => 'cached_forecast_${city.toLowerCase()}';

  // ── Current weather ─────────────────────────────────────────────

  @override
  Future<WeatherModel?> getCachedWeather(String city) async {
    try {
      final jsonStr = _prefs.getString(_weatherKey(city));
      if (jsonStr == null) return null;
      return WeatherModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (_) {
      throw const CacheException('Failed to read cached weather.');
    }
  }

  @override
  Future<void> cacheWeather(WeatherModel weather) async {
    try {
      await _prefs.setString(
        _weatherKey(weather.cityName),
        jsonEncode(weather.toJson()),
      );
    } catch (_) {
      throw const CacheException('Failed to write weather cache.');
    }
  }

  // ── Forecast ───────────────────────────────────────────────────

  @override
  Future<List<ForecastModel>> getCachedForecast(String city) async {
    try {
      final jsonStr = _prefs.getString(_forecastKey(city));
      if (jsonStr == null) return [];
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => ForecastModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const CacheException('Failed to read cached forecast.');
    }
  }

  @override
  Future<void> cacheForecast(String city, List<ForecastModel> forecast) async {
    try {
      await _prefs.setString(
        _forecastKey(city),
        jsonEncode(forecast.map((f) => f.toJson()).toList()),
      );
    } catch (_) {
      throw const CacheException('Failed to write forecast cache.');
    }
  }

  // ── Favourites ────────────────────────────────────────────────

  @override
  Future<List<String>> getFavoriteCities() async =>
      _prefs.getStringList(AppConstants.favoriteCitiesKey) ?? [];

  @override
  Future<void> saveFavoriteCities(List<String> cities) async =>
      _prefs.setStringList(AppConstants.favoriteCitiesKey, cities);

  // ── Last city ─────────────────────────────────────────────────

  @override
  Future<String?> getLastCity() async =>
      _prefs.getString(AppConstants.lastCityKey);

  @override
  Future<void> saveLastCity(String city) async =>
      _prefs.setString(AppConstants.lastCityKey, city);
}
