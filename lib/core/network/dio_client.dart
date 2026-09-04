import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

class DioClient {
  DioClient() : _dio = _buildDio();

  final Dio _dio;

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: Duration(seconds: AppConstants.connectTimeout),
        receiveTimeout: Duration(seconds: AppConstants.receiveTimeout),
        // NOTE: 'units' is intentionally NOT set here.
        // It is passed per-request so the °C/°F toggle works correctly.
        queryParameters: {'appid': AppConstants.apiKey},
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (o) => debugPrint('[DioClient] $o'),
      ),
    );

    return dio;
  }

  /// [units] should be 'metric' (°C) or 'imperial' (°F).
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    String units = 'metric',
  }) async {
    try {
      final params = <String, dynamic>{'units': units, ...?queryParameters};
      return await _dio.get<T>(path, queryParameters: params);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Never _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        throw const NetworkException(
          'Connection timed out. Check your internet.',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) throw const UnauthorizedException();
        if (statusCode == 404) {
          throw CityNotFoundException(
            e.response?.data?['message'] ?? 'unknown',
          );
        }
        throw ServerException(
          message: e.response?.data?['message'] ?? 'Server error.',
          statusCode: statusCode,
        );
      default:
        throw ServerException(message: e.message ?? 'Unknown error.');
    }
  }
}
