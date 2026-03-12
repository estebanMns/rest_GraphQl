// lib/data/datasources/weather_remote_datasource.dart
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../models/weather_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getCurrentWeatherByCity(String cityName);
  Future<WeatherModel> getCurrentWeatherByCoords(double lat, double lon);
  Future<List<ForecastItemModel>> getForecastByCity(String cityName);
  Future<AirQualityModel> getAirQualityByCoords(double lat, double lon);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final ApiClient apiClient;

  WeatherRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<WeatherModel> getCurrentWeatherByCity(String cityName) async {
    try {
      final data = await apiClient.get(
        ApiEndpoints.currentWeather,
        queryParameters: {
          'q': cityName,
          'appid': AppConstants.openWeatherApiKey,
          'units': 'metric',
          'lang': 'es',
        },
      );
      return WeatherModel.fromJson(data);
    } on NotFoundException {
      throw const NotFoundException(message: 'Ciudad no encontrada.');
    } on ServerException catch (e) {
      throw ServerException(message: e.message, statusCode: e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(message: e.message);
    }
  }

  @override
  Future<WeatherModel> getCurrentWeatherByCoords(
      double lat, double lon) async {
    final data = await apiClient.get(
      ApiEndpoints.currentWeather,
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'appid': AppConstants.openWeatherApiKey,
        'units': 'metric',
        'lang': 'es',
      },
    );
    return WeatherModel.fromJson(data);
  }

  @override
  Future<List<ForecastItemModel>> getForecastByCity(String cityName) async {
    final data = await apiClient.get(
      ApiEndpoints.forecast,
      queryParameters: {
        'q': cityName,
        'appid': AppConstants.openWeatherApiKey,
        'units': 'metric',
        'lang': 'es',
        'cnt': 40, // 5 días × 8 intervalos de 3h
      },
    );
    final list = data['list'] as List<dynamic>;
    return list
        .map((item) => ForecastItemModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AirQualityModel> getAirQualityByCoords(
      double lat, double lon) async {
    final data = await apiClient.get(
      ApiEndpoints.airQuality,
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'appid': AppConstants.openWeatherApiKey,
      },
    );
    return AirQualityModel.fromJson(data);
  }
}
