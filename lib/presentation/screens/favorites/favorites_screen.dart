import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/weather.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/weather_provider.dart';
import '../../widgets/cached_weather_icon.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);
    final unitLabel = ref.watch(settingsProvider.select((s) => s.unitLabel));

    return Scaffold(
      appBar: AppBar(title: const Text('Favourite Cities')),
      body: favoritesAsync.when(
        data: (cities) {
          if (cities.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No favourites yet.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  const Text('Search a city and tap ⭐ to save it.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: cities.length,
            itemBuilder: (context, index) {
              final city = cities[index];
              return Dismissible(
                key: ValueKey(city),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) =>
                    ref.read(favoritesProvider.notifier).removeCity(city),
                child: _FavoriteCityTile(
                  city: city,
                  unitLabel: unitLabel,
                  onTap: () {
                    ref.read(weatherProvider.notifier).fetchWeather(city);
                    ref.read(forecastProvider.notifier).fetchForecast(city);
                    Navigator.pop(context);
                  },
                  onRemove: () =>
                      ref.read(favoritesProvider.notifier).removeCity(city),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

/// A single tile that reads cached weather for a city and shows a live preview.
class _FavoriteCityTile extends ConsumerWidget {
  const _FavoriteCityTile({
    required this.city,
    required this.unitLabel,
    required this.onTap,
    required this.onRemove,
  });

  final String city;
  final String unitLabel;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Each tile has its own provider family instance so they don't conflict.
    final cachedWeatherAsync = ref.watch(_favCityWeatherProvider(city));

    return cachedWeatherAsync.when(
      data: (weather) => _buildTile(context, weather),
      loading: () => ListTile(
        leading: const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text(city),
        subtitle: const Text('Loading…'),
      ),
      error: (_, __) => ListTile(
        leading: const Icon(Icons.location_city, size: 40),
        title: Text(city),
        subtitle: const Text('Could not load preview'),
        onTap: onTap,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onRemove,
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, Weather? weather) {
    if (weather == null) {
      return ListTile(
        leading: const Icon(Icons.location_city, size: 40),
        title: Text(city),
        subtitle: const Text('No cached data'),
        onTap: onTap,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onRemove,
        ),
      );
    }

    final diff = DateTime.now().difference(weather.timestamp);
    final age = diff.inMinutes < 60
        ? '${diff.inMinutes}m ago'
        : diff.inHours < 24
            ? '${diff.inHours}h ago'
            : '${diff.inDays}d ago';

    return ListTile(
      onTap: onTap,
      leading: CachedWeatherIcon(url: weather.iconUrl, size: 40),
      title: Text(weather.cityName),
      subtitle: Text(
        '${weather.description}  •  updated $age',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${weather.temperature.toStringAsFixed(0)}$unitLabel',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

/// Per-city provider that reads from local cache.
final _favCityWeatherProvider =
    FutureProvider.family<Weather?, String>((ref, city) async {
  return ref.read(weatherRepositoryProvider).getCurrentWeather(
        city,
        units: ref.read(settingsProvider).apiUnits,
      );
});
