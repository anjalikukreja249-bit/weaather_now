import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/forecast_day.dart';
import '../../providers/settings_provider.dart';
import '../../providers/weather_provider.dart';
import '../../widgets/cached_weather_icon.dart';
import '../../widgets/forecast_strip.dart' show ForecastDetailArgs;

class ForecastDetailScreen extends ConsumerWidget {
  const ForecastDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args =
        ModalRoute.of(context)?.settings.arguments as ForecastDetailArgs?;
    final unitLabel = ref.watch(settingsProvider.select((s) => s.unitLabel));

    // If navigated from strip with a specific day, show its 3-hour slots.
    // If navigated from AppBar "See all", fall back to full forecast list.
    if (args != null) {
      return _DayDetailView(
        slots: args.slots,
        unitLabel: unitLabel,
      );
    }

    // Fallback: show all days summary
    final forecastAsync = ref.watch(forecastProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('5-Day Forecast')),
      body: forecastAsync.when(
        data: (days) {
          if (days.isEmpty) {
            return const Center(child: Text('No forecast data available.'));
          }
          // Group by day for summary
          final Map<String, List<ForecastDay>> byDay = {};
          for (final d in days) {
            final key = '${d.date.year}-${d.date.month}-${d.date.day}';
            byDay.putIfAbsent(key, () => []).add(d);
          }
          final dayKeys = byDay.keys.take(5).toList();
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: dayKeys.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final slots = byDay[dayKeys[index]]!;
              final rep = slots.firstWhere(
                (d) => d.date.hour >= 11 && d.date.hour <= 14,
                orElse: () => slots.first,
              );
              return ListTile(
                leading: CachedWeatherIcon(url: rep.iconUrl, size: 40),
                title: Text(WeatherDateUtils.formatFullDate(rep.date)),
                subtitle: Text(
                    '${rep.description} • ${rep.minTemp.toStringAsFixed(0)} / ${rep.maxTemp.toStringAsFixed(0)}$unitLabel'),
                trailing: Text('💧 ${rep.humidity}%'),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/forecast',
                  arguments: ForecastDetailArgs(
                    dateKey: dayKeys[index],
                    slots: slots,
                  ),
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

/// Shows 3-hour slots for a single day.
class _DayDetailView extends StatelessWidget {
  const _DayDetailView({
    required this.slots,
    required this.unitLabel,
  });

  final List<ForecastDay> slots;
  final String unitLabel;

  String _slotLabel(DateTime dt) {
    final h = dt.hour;
    if (h >= 5 && h < 12) return 'Morning';
    if (h >= 12 && h < 17) return 'Afternoon';
    if (h >= 17 && h < 21) return 'Evening';
    return 'Night';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = slots.first.date;
    return Scaffold(
      appBar: AppBar(
        title: Text(WeatherDateUtils.formatFullDate(date)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: slots.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final slot = slots[i];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CachedWeatherIcon(url: slot.iconUrl, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${WeatherDateUtils.formatTime(slot.date)}  —  ${_slotLabel(slot.date)}',
                          style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary),
                        ),
                        Text(
                          slot.description,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${slot.maxTemp.toStringAsFixed(0)}$unitLabel',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '💧 ${slot.humidity}%  💨 ${slot.windSpeed.toStringAsFixed(1)} m/s',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
