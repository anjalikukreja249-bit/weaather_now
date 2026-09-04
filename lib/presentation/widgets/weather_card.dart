import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/weather.dart';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';
import 'cached_weather_icon.dart';

class WeatherCard extends ConsumerWidget {
  const WeatherCard({super.key, required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final unitLabel = ref.watch(settingsProvider.select((s) => s.unitLabel));
    final isFav = ref.watch(
      favoritesProvider.select(
        (v) => v.valueOrNull?.contains(weather.cityName) ?? false,
      ),
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // City + favourite toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.cityName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      weather.country,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : null,
                  ),
                  onPressed: () {
                    if (isFav) {
                      ref
                          .read(favoritesProvider.notifier)
                          .removeCity(weather.cityName);
                    } else {
                      ref
                          .read(favoritesProvider.notifier)
                          .addCity(weather.cityName);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Temperature + icon
            Row(
              children: [
                CachedWeatherIcon(url: weather.iconUrl, size: 64),
                const SizedBox(width: 8),
                Text(
                  '${weather.temperature.toStringAsFixed(1)}$unitLabel',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),

            Text(
              weather.description.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                letterSpacing: 1.2,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // Detail row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DetailChip(
                  icon: Icons.thermostat,
                  label: 'Feels like',
                  value: '${weather.feelsLike.toStringAsFixed(1)}$unitLabel',
                ),
                _DetailChip(
                  icon: Icons.water_drop,
                  label: 'Humidity',
                  value: '${weather.humidity}%',
                ),
                _DetailChip(
                  icon: Icons.air,
                  label: 'Wind',
                  value: '${weather.windSpeed} m/s',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _staleness(weather.timestamp),
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// Returns a human-readable staleness string, e.g. "Updated 2h ago" or "Updated just now".
String _staleness(DateTime timestamp) {
  final diff = DateTime.now().difference(timestamp);
  if (diff.inMinutes < 1) return 'Updated just now';
  if (diff.inHours < 1) return 'Updated ${diff.inMinutes}m ago';
  if (diff.inHours < 24) return 'Updated ${diff.inHours}h ago';
  return 'Updated ${diff.inDays}d ago';
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
