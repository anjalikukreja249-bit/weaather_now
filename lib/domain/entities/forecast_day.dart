/// Pure domain entity representing a single forecast day.
/// No Flutter imports, no JSON serialisation.
class ForecastDay {
  const ForecastDay({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
  });

  final DateTime date;

  /// Minimum temperature in °C.
  final double minTemp;

  /// Maximum temperature in °C.
  final double maxTemp;

  final String description;

  /// OWM icon code (e.g. "01d").
  final String iconCode;

  final int humidity;

  /// Wind speed in m/s.
  final double windSpeed;

  String get iconUrl =>
      'https://openweathermap.org/img/wn/$iconCode@2x.png';

  @override
  String toString() =>
      'ForecastDay(${date.toIso8601String()}, '
      '${minTemp.toStringAsFixed(1)}–${maxTemp.toStringAsFixed(1)}°C)';
}
