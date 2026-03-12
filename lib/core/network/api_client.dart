// lib/core/network/api_client.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../errors/failures.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.openWeatherBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptors para logging y manejo de errores
    _dio.interceptors.addAll([
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (log) => print('[API] $log'),
      ),
      InterceptorsWrapper(
        onError: (DioException e, ErrorInterceptorHandler handler) {
          handler.next(e);
        },
      ),
    ]);
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
            message: 'Tiempo de conexión agotado. Verifica tu internet.');
      case DioExceptionType.connectionError:
        return const NetworkException(message: 'Sin conexión a internet.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          return const NotFoundException(message: 'Ciudad no encontrada.');
        } else if (statusCode == 401) {
          return const ServerException(
              message: 'API Key inválida.', statusCode: 401);
        }
        return ServerException(
          message: e.response?.data?['message'] ?? 'Error del servidor.',
          statusCode: statusCode,
        );
      default:
        return ServerException(
            message: e.message ?? 'Error desconocido.', statusCode: null);
    }
  }
}

// Open Meteo client (sin API key, para demostración adicional)
class OpenMeteoClient {
  late final Dio _dio;

  OpenMeteoClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.openMeteoBase,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
  }

  Future<Map<String, dynamic>> getForecast({
    required double latitude,
    required double longitude,
    List<String> hourlyVars = const [
      'temperature_2m',
      'relative_humidity_2m',
      'wind_speed_10m',
      'weather_code',
      'precipitation_probability',
    ],
    List<String> dailyVars = const [
      'temperature_2m_max',
      'temperature_2m_min',
      'weather_code',
      'precipitation_sum',
      'wind_speed_10m_max',
    ],
  }) async {
    try {
      final response = await _dio.get(
        '/forecast',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'hourly': hourlyVars.join(','),
          'daily': dailyVars.join(','),
          'timezone': 'auto',
          'forecast_days': 7,
          'wind_speed_unit': 'kmh',
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Error al obtener pronóstico.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
