import '../../domain/entities/weather.dart';

class WeatherModel extends Weather {
  const WeatherModel({
    required super.cityName,
    required super.country,
    required super.temperature,
    required super.feelsLike,
    required super.humidity,
    required super.windSpeed,
    required super.description,
    required super.iconCode,
    required super.timestamp,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] as String,
      country: (json['sys'] as Map<String, dynamic>)['country'] as String,
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      humidity: (json['main']['humidity'] as num).toInt(),
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      description: (json['weather'][0]['description'] as String),
      iconCode: (json['weather'][0]['icon'] as String),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int) * 1000,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': cityName,
        'sys': {'country': country},
        'main': {
          'temp': temperature,
          'feels_like': feelsLike,
          'humidity': humidity,
        },
        'wind': {'speed': windSpeed},
        'weather': [
          {'description': description, 'icon': iconCode},
        ],
        'dt': timestamp.millisecondsSinceEpoch ~/ 1000,
      };
}
