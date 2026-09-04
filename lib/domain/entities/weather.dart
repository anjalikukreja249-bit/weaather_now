/// Pure domain entity — no Flutter imports, no JSON serialisation.
class Weather {
  const Weather({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.iconCode,
    required this.timestamp,
  });

  final String cityName;
  final String country;

  /// Temperature in °C.
  final double temperature;

  /// "Feels like" temperature in °C.
  final double feelsLike;

  /// Humidity percentage (0–100).
  final int humidity;

  /// Wind speed in m/s.
  final double windSpeed;

  /// Human-readable weather description (e.g. "light rain").
  final String description;

  /// OWM icon code (e.g. "10d").
  final String iconCode;

  /// Time of the data snapshot.
  final DateTime timestamp;

  String get iconUrl =>
      'https://openweathermap.org/img/wn/$iconCode@2x.png';

  @override
  String toString() =>
      'Weather($cityName, ${temperature.toStringAsFixed(1)}°C, $description)';
}
