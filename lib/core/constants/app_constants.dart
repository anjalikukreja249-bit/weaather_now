import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  // API
  static String get apiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String iconBaseUrl = 'https://openweathermap.org/img/wn';

  // Cache
  static const String cachedWeatherKey = 'cached_weather';
  static const String favoriteCitiesKey = 'favorite_cities';
  static const String lastCityKey = 'last_searched_city';
  static const int cacheMaxAgeMinutes = 30;

  // Forecast
  static const int forecastDays = 5;

  // Timeouts (seconds)
  static const int connectTimeout = 10;
  static const int receiveTimeout = 10;
}
