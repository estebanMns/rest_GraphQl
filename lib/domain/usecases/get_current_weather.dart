// lib/domain/usecases/get_current_weather.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';
import '../entities/weather_entity.dart';
import '../repositories/weather_repository.dart';

/// Base UseCase genérico
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}

// ── REST USE CASES ──────────────────────────────────────────────

/// Caso de uso: obtener clima actual por ciudad (REST)
class GetCurrentWeatherByCityUseCase
    implements UseCase<WeatherEntity, CityParams> {
  final WeatherRepository repository;

  GetCurrentWeatherByCityUseCase(this.repository);

  @override
  Future<Either<Failure, WeatherEntity>> call(CityParams params) {
    return repository.getCurrentWeatherByCity(params.cityName);
  }
}

/// Caso de uso: obtener pronóstico 5 días (REST)
class GetForecastByCityUseCase
    implements UseCase<List<ForecastEntity>, CityParams> {
  final WeatherRepository repository;

  GetForecastByCityUseCase(this.repository);

  @override
  Future<Either<Failure, List<ForecastEntity>>> call(CityParams params) {
    return repository.getForecastByCity(params.cityName);
  }
}

/// Caso de uso: obtener calidad del aire (REST)
class GetAirQualityUseCase
    implements UseCase<AirQualityEntity, CoordsParams> {
  final WeatherRepository repository;

  GetAirQualityUseCase(this.repository);

  @override
  Future<Either<Failure, AirQualityEntity>> call(CoordsParams params) {
    return repository.getAirQualityByCoords(params.lat, params.lon);
  }
}

// ── GRAPHQL USE CASES ────────────────────────────────────────────

/// Caso de uso: obtener clima via GraphQL
class GetCurrentWeatherGraphQLUseCase
    implements UseCase<WeatherEntity, GraphQLCityParams> {
  final WeatherGraphQLRepository repository;

  GetCurrentWeatherGraphQLUseCase(this.repository);

  @override
  Future<Either<Failure, WeatherEntity>> call(GraphQLCityParams params) {
    return repository.getCurrentWeatherGraphQL(
      params.cityName,
      country: params.country,
      units: params.units,
    );
  }
}

// ── PARAMS ────────────────────────────────────────────────────────

class CityParams extends Equatable {
  final String cityName;
  const CityParams({required this.cityName});

  @override
  List<Object?> get props => [cityName];
}

class CoordsParams extends Equatable {
  final double lat;
  final double lon;
  const CoordsParams({required this.lat, required this.lon});

  @override
  List<Object?> get props => [lat, lon];
}

class GraphQLCityParams extends Equatable {
  final String cityName;
  final String? country;
  final String? units;
  const GraphQLCityParams({
    required this.cityName,
    this.country,
    this.units = 'metric',
  });

  @override
  List<Object?> get props => [cityName, country, units];
}
