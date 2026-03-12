// lib/data/repositories/weather_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_datasource.dart';
import '../datasources/weather_graphql_datasource.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;

  WeatherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, WeatherEntity>> getCurrentWeatherByCity(
      String cityName) async {
    try {
      final model = await remoteDataSource.getCurrentWeatherByCity(cityName);
      return Right(model.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WeatherEntity>> getCurrentWeatherByCoords(
      double lat, double lon) async {
    try {
      final model =
          await remoteDataSource.getCurrentWeatherByCoords(lat, lon);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ForecastEntity>>> getForecastByCity(
      String cityName) async {
    try {
      final models =
          await remoteDataSource.getForecastByCity(cityName);
      return Right(models.map((m) => m.toEntity()).toList());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AirQualityEntity>> getAirQualityByCoords(
      double lat, double lon) async {
    try {
      final model =
          await remoteDataSource.getAirQualityByCoords(lat, lon);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

// lib/data/repositories/weather_graphql_repository_impl.dart


class WeatherGraphQLRepositoryImpl implements WeatherGraphQLRepository {
  final WeatherGraphQLDataSource graphqlDataSource;

  WeatherGraphQLRepositoryImpl({required this.graphqlDataSource});

  @override
  Future<Either<Failure, WeatherEntity>> getCurrentWeatherGraphQL(
      String cityName, {String? country, String? units}) async {
    try {
      final model = await graphqlDataSource.getCurrentWeatherGraphQL(
        cityName,
        country: country,
        units: units,
      );
      return Right(model.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on GraphQLException catch (e) {
      return Left(GraphQLFailure(message: e.message, errors: e.errors));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(GraphQLFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WeatherEntity>> getWeatherByCoordsGraphQL(
      double lat, double lon) async {
    try {
      final model =
          await graphqlDataSource.getWeatherByCoordsGraphQL(lat, lon);
      return Right(model.toEntity());
    } on GraphQLException catch (e) {
      return Left(GraphQLFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(GraphQLFailure(message: e.toString()));
    }
  }
}
