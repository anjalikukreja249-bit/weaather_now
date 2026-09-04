import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/forecast/forecast_detail_screen.dart';
import 'presentation/screens/favorites/favorites_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/providers/settings_provider.dart';

class WeatherNowApp extends ConsumerWidget {
  const WeatherNowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'WeatherNow',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/forecast': (_) => const ForecastDetailScreen(),
        '/favorites': (_) => const FavoritesScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}
