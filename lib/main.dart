import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'presentation/providers/weather_provider.dart';
import 'presentation/providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Both providers that need SharedPreferences are overridden here
        // so the real instance is available before any widget builds.
        sharedPreferencesProvider.overrideWithValue(prefs),
        settingsPrefsProvider.overrideWithValue(prefs),
      ],
      child: const WeatherNowApp(),
    ),
  );
}
