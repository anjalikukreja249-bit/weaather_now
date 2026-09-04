import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/forecast_day.dart';
import 'cached_weather_icon.dart';

class ForecastStrip extends ConsumerWidget {
  const ForecastStrip({super.key, required this.days});

  final List<ForecastDay> days;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group 3-hour slots by calendar day; preserve all slots per day for detail view
    final Map<String, List<ForecastDay>> byDay = {};
    for (final d in days) {
      final key = '${d.date.year}-${d.date.month}-${d.date.day}';
      byDay.putIfAbsent(key, () => []).add(d);
    }
    final dayKeys = byDay.keys.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '5-Day Forecast',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/forecast'),
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dayKeys.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final key = dayKeys[index];
              final slotsForDay = byDay[key]!;
              // Representative entry: pick midday slot if available
              final rep = slotsForDay.firstWhere(
                (d) => d.date.hour >= 11 && d.date.hour <= 14,
                orElse: () => slotsForDay.first,
              );
              final isToday = WeatherDateUtils.isToday(rep.date);
              return _ForecastChip(
                day: rep,
                isToday: isToday,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/forecast',
                  arguments: ForecastDetailArgs(
                    dateKey: key,
                    slots: slotsForDay,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Route argument passed to ForecastDetailScreen.
class ForecastDetailArgs {
  const ForecastDetailArgs({required this.dateKey, required this.slots});
  final String dateKey;
  final List<ForecastDay> slots;
}

class _ForecastChip extends StatelessWidget {
  const _ForecastChip({
    required this.day,
    required this.isToday,
    this.onTap,
  });

  final ForecastDay day;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isToday
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: onTap != null
              ? Border.all(color: theme.colorScheme.outline.withOpacity(0.3))
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              isToday ? 'Today' : WeatherDateUtils.formatWeekday(day.date),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isToday ? theme.colorScheme.onPrimaryContainer : null,
              ),
            ),
            CachedWeatherIcon(url: day.iconUrl, size: 32),
            Text(
              '${day.maxTemp.toStringAsFixed(0)}°',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '${day.minTemp.toStringAsFixed(0)}°',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
