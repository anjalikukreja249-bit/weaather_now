import '../entities/weather.dart';
import '../entities/forecast_day.dart';

/// Abstract contract for weather data access.
/// The data layer implements this; the presentation layer depends on it.
abstract interface class WeatherRepository {
  /// Fetches current weather for [city].
  /// [units]: 'metric' (°C) or 'imperial' (°F).
  /// Falls back to local cache when offline.
  Future<Weather> getCurrentWeather(String city, {String units});

  /// Fetches a 5-day forecast for [city].
  /// Falls back to cached forecast when offline.
  Future<List<ForecastDay>> getForecast(String city, {String units});

  /// Returns the list of saved favourite city names.
  Future<List<String>> getFavoriteCities();

  /// Persists the [cities] list to local storage.
  Future<void> saveFavoriteCities(List<String> cities);

  /// Returns the last searched city name, or null.
  Future<String?> getLastCity();

  /// Persists [city] as the last searched city.
  Future<void> saveLastCity(String city);
}
