import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_provider.dart';
import '../../providers/weather_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Units section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('Units',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary)),
          ),
          SwitchListTile(
            title: const Text('Temperature Unit'),
            subtitle: Text(settings.isCelsius
                ? 'Currently showing °C (Celsius)'
                : 'Currently showing °F (Fahrenheit)'),
            secondary: Text(
              settings.unitLabel,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            value: settings.isCelsius,
            onChanged: (_) {
              ref.read(settingsProvider.notifier).toggleUnit();
              final newUnits = ref.read(settingsProvider).apiUnits;
              // Immediately refresh both providers so all screens update live
              ref.read(weatherProvider.notifier).refreshWithUnits(newUnits);
              ref.read(forecastProvider.notifier).refreshWithUnits(newUnits);
            },
          ),
          const Divider(),
          // Appearance section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text('Appearance',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary)),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle light / dark theme'),
            secondary: const Icon(Icons.dark_mode),
            value: settings.themeMode == ThemeMode.dark,
            onChanged: (_) =>
                ref.read(settingsProvider.notifier).toggleTheme(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('WeatherNow v1.0.0'),
          ),
        ],
      ),
    );
  }
}
