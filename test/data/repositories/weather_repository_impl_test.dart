import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:weather_now/core/errors/exceptions.dart';
import 'package:weather_now/core/utils/connectivity_helper.dart';
import 'package:weather_now/data/datasources/local/weather_local_datasource.dart';
import 'package:weather_now/data/datasources/remote/weather_remote_datasource.dart';
import 'package:weather_now/data/models/weather_model.dart';
import 'package:weather_now/data/repositories/weather_repository_impl.dart';

@GenerateMocks([
  WeatherRemoteDataSource,
  WeatherLocalDataSource,
  ConnectivityHelper,
])
import 'weather_repository_impl_test.mocks.dart';

/// Minimal WeatherModel fixture.
WeatherModel _fixture({String city = 'Tokyo'}) => WeatherModel(
      cityName: city,
      country: 'JP',
      temperature: 22.0,
      feelsLike: 20.0,
      humidity: 60,
      windSpeed: 3.5,
      description: 'clear sky',
      iconCode: '01d',
      timestamp: DateTime(2024, 1, 1, 12),
    );

void main() {
  late MockWeatherRemoteDataSource remote;
  late MockWeatherLocalDataSource local;
  late MockConnectivityHelper connectivity;
  late WeatherRepositoryImpl repo;

  setUp(() {
    remote = MockWeatherRemoteDataSource();
    local = MockWeatherLocalDataSource();
    connectivity = MockConnectivityHelper();
    repo = WeatherRepositoryImpl(
      remote: remote,
      local: local,
      connectivity: connectivity,
    );
  });

  group('getCurrentWeather', () {
    test('fetches from remote and caches when online', () async {
      final weather = _fixture();
      when(connectivity.isConnected).thenAnswer((_) async => true);
      when(remote.getCurrentWeather('Tokyo', units: 'metric'))
          .thenAnswer((_) async => weather);
      when(local.cacheWeather(weather)).thenAnswer((_) async {});
      when(local.saveLastCity('Tokyo')).thenAnswer((_) async {});

      final result = await repo.getCurrentWeather('Tokyo');

      expect(result.cityName, 'Tokyo');
      verify(local.cacheWeather(weather)).called(1);
    });

    test('returns cached data when offline and cache exists', () async {
      final cached = _fixture();
      when(connectivity.isConnected).thenAnswer((_) async => false);
      when(local.getCachedWeather('Tokyo')).thenAnswer((_) async => cached);

      final result = await repo.getCurrentWeather('Tokyo');

      expect(result.cityName, 'Tokyo');
      verifyNever(remote.getCurrentWeather(any));
    });

    test('throws NetworkException when offline and no cache', () async {
      when(connectivity.isConnected).thenAnswer((_) async => false);
      when(local.getCachedWeather('Tokyo')).thenAnswer((_) async => null);

      expect(
        () => repo.getCurrentWeather('Tokyo'),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('getForecast', () {
    test('throws NetworkException and falls back to cache when offline', () async {
      when(connectivity.isConnected).thenAnswer((_) async => false);
      when(local.getCachedForecast('Tokyo')).thenAnswer((_) async => []);

      expect(
        () => repo.getForecast('Tokyo'),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('getLastCity / saveLastCity', () {
    test('delegates to local datasource', () async {
      when(local.getLastCity()).thenAnswer((_) async => 'Paris');
      final city = await repo.getLastCity();
      expect(city, 'Paris');
    });

    test('saves last city via local datasource', () async {
      when(local.saveLastCity('Berlin')).thenAnswer((_) async {});
      await repo.saveLastCity('Berlin');
      verify(local.saveLastCity('Berlin')).called(1);
    });
  });
}
