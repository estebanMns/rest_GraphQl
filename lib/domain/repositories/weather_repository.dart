// lib/domain/repositories/weather_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/weather_entity.dart';

/// Contrato abstracto del repositorio de clima (REST)
abstract class WeatherRepository {
  /// Obtiene el clima actual por nombre de ciudad via REST
  Future<Either<Failure, WeatherEntity>> getCurrentWeatherByCity(
      String cityName);

  /// Obtiene el clima actual por coordenadas via REST
  Future<Either<Failure, WeatherEntity>> getCurrentWeatherByCoords(
      double lat, double lon);

  /// Obtiene el pronóstico de 5 días via REST
  Future<Either<Failure, List<ForecastEntity>>> getForecastByCity(
      String cityName);

  /// Obtiene la calidad del aire por coordenadas via REST
  Future<Either<Failure, AirQualityEntity>> getAirQualityByCoords(
      double lat, double lon);
}

/// Contrato abstracto del repositorio de clima (GraphQL)
abstract class WeatherGraphQLRepository {
  /// Obtiene el clima actual por nombre de ciudad via GraphQL
  Future<Either<Failure, WeatherEntity>> getCurrentWeatherGraphQL(
      String cityName, {String? country, String? units});

  /// Obtiene el clima por coordenadas via GraphQL
  Future<Either<Failure, WeatherEntity>> getWeatherByCoordsGraphQL(
      double lat, double lon);
}
