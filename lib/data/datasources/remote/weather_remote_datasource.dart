import '../../../core/network/dio_client.dart';
import '../../models/weather_model.dart';
import '../../models/forecast_model.dart';

abstract interface class WeatherRemoteDataSource {
  Future<WeatherModel> getCurrentWeather(String city, {String units});
  Future<List<ForecastModel>> getForecast(String city, {String units});
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  const WeatherRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<WeatherModel> getCurrentWeather(
    String city, {
    String units = 'metric',
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/weather',
      queryParameters: {'q': city},
      units: units,
    );
    return WeatherModel.fromJson(response.data!);
  }

  @override
  Future<List<ForecastModel>> getForecast(
    String city, {
    String units = 'metric',
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/forecast',
      queryParameters: {'q': city, 'cnt': 40}, // 5 days × 8 slots
      units: units,
    );
    final list = response.data!['list'] as List<dynamic>;
    return list
        .map((e) => ForecastModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
