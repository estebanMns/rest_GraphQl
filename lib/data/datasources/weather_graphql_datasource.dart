// lib/data/datasources/weather_graphql_datasource.dart
import 'package:graphql_flutter/graphql_flutter.dart' hide NetworkException;
import '../../core/errors/failures.dart';
import '../../core/network/graphql_client.dart';
import '../models/weather_graphql_model.dart';

abstract class WeatherGraphQLDataSource {
  Future<WeatherGraphQLModel> getCurrentWeatherGraphQL(
      String cityName, {String? country, String? units});
  Future<WeatherGraphQLModel> getWeatherByCoordsGraphQL(
      double lat, double lon);
}

class WeatherGraphQLDataSourceImpl implements WeatherGraphQLDataSource {
  final GraphQLClient client;

  WeatherGraphQLDataSourceImpl({required this.client});

  @override
  Future<WeatherGraphQLModel> getCurrentWeatherGraphQL(
    String cityName, {
    String? country,
    String? units,
  }) async {
    try {
      final result = await client.query(
        QueryOptions(
          document: gql(WeatherQueries.getCurrentWeather),
          variables: {
            'name': cityName,
            'country': ?country,
            'config': {'units': units ?? 'metric', 'lang': 'es'},
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        final errors = result.exception?.graphqlErrors
            .map((e) => e.message)
            .toList();

        if (result.exception?.linkException != null) {
          throw const NetworkException(
              message: 'No se pudo conectar al servidor GraphQL.');
        }

        throw GraphQLException(
          message: errors?.first ?? 'Error en consulta GraphQL.',
          errors: errors,
        );
      }

      final cityData =
          result.data?['getCityByName'] as Map<String, dynamic>?;

      if (cityData == null) {
        throw const NotFoundException(
            message: 'Ciudad no encontrada via GraphQL.');
      }

      return WeatherGraphQLModel.fromGraphQL(cityData);
    } on GraphQLException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw GraphQLException(
          message: 'Error inesperado en GraphQL: ${e.toString()}');
    }
  }

  @override
  Future<WeatherGraphQLModel> getWeatherByCoordsGraphQL(
      double lat, double lon) async {
    final result = await client.query(
      QueryOptions(
        document: gql(WeatherQueries.getWeatherByCoords),
        variables: {
          'lat': lat,
          'lon': lon,
          'config': {'units': 'metric', 'lang': 'es'},
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw GraphQLException(
        message:
            result.exception?.graphqlErrors.first.message ?? 'Error GraphQL.',
      );
    }

    final cityData =
        result.data?['getCityByCoordinates'] as Map<String, dynamic>?;
    if (cityData == null) {
      throw const NotFoundException(message: 'No se encontraron datos.');
    }

    return WeatherGraphQLModel.fromGraphQL(cityData);
  }
}
