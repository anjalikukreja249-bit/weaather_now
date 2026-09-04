import 'package:flutter_test/flutter_test.dart';
import 'package:weather_now/data/models/weather_model.dart';

void main() {
  group('WeatherModel.fromJson', () {
    final validJson = {
      'name': 'London',
      'sys': {'country': 'GB'},
      'main': {
        'temp': 15.5,
        'feels_like': 13.2,
        'humidity': 72,
      },
      'wind': {'speed': 4.1},
      'weather': [
        {'description': 'light rain', 'icon': '10d'},
      ],
      'dt': 1700000000,
    };

    test('parses city name and country', () {
      final model = WeatherModel.fromJson(validJson);
      expect(model.cityName, 'London');
      expect(model.country, 'GB');
    });

    test('parses temperature fields as doubles', () {
      final model = WeatherModel.fromJson(validJson);
      expect(model.temperature, 15.5);
      expect(model.feelsLike, 13.2);
    });

    test('parses humidity as int', () {
      final model = WeatherModel.fromJson(validJson);
      expect(model.humidity, 72);
    });

    test('parses description and icon code', () {
      final model = WeatherModel.fromJson(validJson);
      expect(model.description, 'light rain');
      expect(model.iconCode, '10d');
    });

    test('parses unix timestamp to DateTime', () {
      final model = WeatherModel.fromJson(validJson);
      expect(
        model.timestamp,
        DateTime.fromMillisecondsSinceEpoch(1700000000 * 1000),
      );
    });

    test('iconUrl is correctly formed', () {
      final model = WeatherModel.fromJson(validJson);
      expect(model.iconUrl,
          'https://openweathermap.org/img/wn/10d@2x.png');
    });

    test('toJson round-trips back to equivalent model', () {
      final original = WeatherModel.fromJson(validJson);
      final roundTripped = WeatherModel.fromJson(original.toJson());
      expect(roundTripped.cityName, original.cityName);
      expect(roundTripped.temperature, original.temperature);
      expect(roundTripped.timestamp, original.timestamp);
    });

    test('throws when required field is missing', () {
      final badJson = Map<String, dynamic>.from(validJson)..remove('name');
      expect(() => WeatherModel.fromJson(badJson), throwsA(anything));
    });
  });
}
