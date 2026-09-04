import '../../domain/entities/forecast_day.dart';

class ForecastModel extends ForecastDay {
  const ForecastModel({
    required super.date,
    required super.minTemp,
    required super.maxTemp,
    required super.description,
    required super.iconCode,
    required super.humidity,
    required super.windSpeed,
  });

  /// Parses a single 3-hour forecast entry from the OWM `/forecast` endpoint.
  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      date: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int) * 1000,
      ),
      minTemp: (json['main']['temp_min'] as num).toDouble(),
      maxTemp: (json['main']['temp_max'] as num).toDouble(),
      description: json['weather'][0]['description'] as String,
      iconCode: json['weather'][0]['icon'] as String,
      humidity: (json['main']['humidity'] as num).toInt(),
      windSpeed: (json['wind']['speed'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'dt': date.millisecondsSinceEpoch ~/ 1000,
        'main': {
          'temp_min': minTemp,
          'temp_max': maxTemp,
          'humidity': humidity,
        },
        'weather': [
          {'description': description, 'icon': iconCode},
        ],
        'wind': {'speed': windSpeed},
      };
}
