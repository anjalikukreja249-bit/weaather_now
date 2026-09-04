/// Thrown when the device has no internet connection.
class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection.']);

  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when the API returns a non-2xx status code.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    this.message = 'An unexpected server error occurred.',
    this.statusCode,
  });

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Thrown when the API key is missing or invalid.
class UnauthorizedException implements Exception {
  const UnauthorizedException();

  @override
  String toString() => 'UnauthorizedException: Invalid or missing API key.';
}

/// Thrown when a requested city is not found.
class CityNotFoundException implements Exception {
  final String city;
  const CityNotFoundException(this.city);

  @override
  String toString() => 'CityNotFoundException: City "$city" not found.';
}

/// Thrown when local cache read/write fails.
class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache operation failed.']);

  @override
  String toString() => 'CacheException: $message';
}
