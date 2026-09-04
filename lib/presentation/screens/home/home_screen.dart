import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/exceptions.dart';
import '../../providers/weather_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/weather_card.dart';
import '../../widgets/forecast_strip.dart';
import '../../widgets/offline_banner.dart';

String _friendlyError(Object e) {
  if (e is NetworkException) return 'No internet connection. Showing cached data.';
  if (e is CityNotFoundException) return 'City not found. Please check the name.';
  if (e is UnauthorizedException) return 'Invalid API key. Check your .env file.';
  if (e is ServerException) return 'Server error. Please try again later.';
  return 'Something went wrong. Please try again.';
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.orange),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    final city = _searchController.text.trim();
    if (city.isEmpty) return;
    ref.read(weatherProvider.notifier).fetchWeather(city);
    ref.read(forecastProvider.notifier).fetchForecast(city);
  }

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(weatherProvider);
    final forecastAsync = ref.watch(forecastProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WeatherNow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
            tooltip: 'Favourites',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search city…',
              trailing: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
              ],
              onSubmitted: (_) => _search(),
            ),
          ),
          Expanded(
            child: weatherAsync.when(
              data: (weather) {
                if (weather == null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_outlined,
                            size: 72, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'Search for a city above',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Type a city name and press search',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    WeatherCard(weather: weather),
                    const SizedBox(height: 16),
                    forecastAsync.when(
                      data: (days) => days.isEmpty
                          ? const SizedBox.shrink()
                          : ForecastStrip(days: days),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => _ErrorCard(
                        message: _friendlyError(e),
                        onRetry: () => ref
                            .read(forecastProvider.notifier)
                            .fetchForecast(
                                weatherAsync.value!.cityName),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorCard(
                message: _friendlyError(e),
                onRetry: () {
                  final city = _searchController.text.trim();
                  if (city.isNotEmpty) _search();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
