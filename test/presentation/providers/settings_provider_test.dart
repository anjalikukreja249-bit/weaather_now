import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weather_now/presentation/providers/settings_provider.dart';

void main() {
  group('SettingsNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      // Use an in-memory SharedPreferences instance for tests.
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      container = ProviderContainer(
        overrides: [
          settingsPrefsProvider.overrideWithValue(prefs),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('defaults to Celsius and system theme', () {
      final settings = container.read(settingsProvider);
      expect(settings.isCelsius, true);
      expect(settings.unitLabel, '°C');
      expect(settings.apiUnits, 'metric');
    });

    test('toggleUnit switches to Fahrenheit', () {
      container.read(settingsProvider.notifier).toggleUnit();
      final settings = container.read(settingsProvider);
      expect(settings.isCelsius, false);
      expect(settings.unitLabel, '°F');
      expect(settings.apiUnits, 'imperial');
    });

    test('toggleUnit twice returns to Celsius', () {
      container.read(settingsProvider.notifier).toggleUnit();
      container.read(settingsProvider.notifier).toggleUnit();
      final settings = container.read(settingsProvider);
      expect(settings.isCelsius, true);
    });

    test('toggleTheme switches to dark mode', () {
      container.read(settingsProvider.notifier).toggleTheme();
      final settings = container.read(settingsProvider);
      expect(settings.themeMode, ThemeMode.dark);
    });

    test('unit preference is persisted to SharedPreferences', () async {
      container.read(settingsProvider.notifier).toggleUnit();
      final prefs = container.read(settingsPrefsProvider);
      // Give async write a moment
      await Future<void>.delayed(Duration.zero);
      expect(prefs.getBool('settings_unit_celsius'), false);
    });

    test('reads persisted unit on startup', () async {
      // Pre-seed prefs with Fahrenheit
      SharedPreferences.setMockInitialValues({
        'settings_unit_celsius': false,
        'settings_theme_dark': true,
      });
      final prefs = await SharedPreferences.getInstance();

      final newContainer = ProviderContainer(
        overrides: [settingsPrefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(newContainer.dispose);

      final settings = newContainer.read(settingsProvider);
      expect(settings.isCelsius, false);
      expect(settings.themeMode, ThemeMode.dark);
    });
  });
}
