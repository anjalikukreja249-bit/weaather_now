import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'weather_provider.dart';

class FavoritesNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() =>
      ref.read(weatherRepositoryProvider).getFavoriteCities();

  Future<void> addCity(String city) async {
    final current = state.valueOrNull ?? [];
    if (current.contains(city)) return;
    final updated = [...current, city];
    await ref.read(weatherRepositoryProvider).saveFavoriteCities(updated);
    state = AsyncData(updated);
  }

  Future<void> removeCity(String city) async {
    final current = state.valueOrNull ?? [];
    final updated = current.where((c) => c != city).toList();
    await ref.read(weatherRepositoryProvider).saveFavoriteCities(updated);
    state = AsyncData(updated);
  }

  bool isFavorite(String city) =>
      state.valueOrNull?.contains(city) ?? false;
}

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<String>>(
        FavoritesNotifier.new);
