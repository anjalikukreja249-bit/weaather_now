import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Keys ──────────────────────────────────────────────────────────────────────
const _kThemeKey = 'settings_theme_dark';
const _kUnitKey = 'settings_unit_celsius';

// ── Model ─────────────────────────────────────────────────────────────────────
class AppSettings {
  const AppSettings({this.themeMode = ThemeMode.system, this.isCelsius = true});

  final ThemeMode themeMode;

  /// true = °C (metric), false = °F (imperial)
  final bool isCelsius;

  String get unitLabel => isCelsius ? '°C' : '°F';
  String get apiUnits => isCelsius ? 'metric' : 'imperial';

  AppSettings copyWith({ThemeMode? themeMode, bool? isCelsius}) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    isCelsius: isCelsius ?? this.isCelsius,
  );
}

// ── Notifier ──────────────────────────────────────────────────────────────────
class SettingsNotifier extends Notifier<AppSettings> {
  late SharedPreferences _prefs;

  @override
  AppSettings build() {
    _prefs = ref.read(settingsPrefsProvider);
    final isDark = _prefs.getBool(_kThemeKey) ?? false;
    final isCelsius = _prefs.getBool(_kUnitKey) ?? true;
    return AppSettings(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      isCelsius: isCelsius,
    );
  }

  void toggleTheme() {
    final isDark = state.themeMode != ThemeMode.dark;
    _prefs.setBool(_kThemeKey, isDark);
    state = state.copyWith(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
    );
  }

  void toggleUnit() {
    final isCelsius = !state.isCelsius;
    _prefs.setBool(_kUnitKey, isCelsius);
    state = state.copyWith(isCelsius: isCelsius);
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

/// Must be overridden in main.dart with the real SharedPreferences instance.
final settingsPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override settingsPrefsProvider in ProviderScope.');
});

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

