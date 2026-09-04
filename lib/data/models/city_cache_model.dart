/// Lightweight model used to persist recently searched / favourite cities
/// in local storage.
class CityCacheModel {
  const CityCacheModel({
    required this.name,
    required this.country,
    required this.cachedAt,
  });

  final String name;
  final String country;
  final DateTime cachedAt;

  factory CityCacheModel.fromJson(Map<String, dynamic> json) {
    return CityCacheModel(
      name: json['name'] as String,
      country: json['country'] as String,
      cachedAt: DateTime.parse(json['cachedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'country': country,
        'cachedAt': cachedAt.toIso8601String(),
      };

  /// Returns `true` if the cache entry is older than [maxAgeMinutes].
  bool isStale(int maxAgeMinutes) {
    return DateTime.now().difference(cachedAt).inMinutes > maxAgeMinutes;
  }
}
