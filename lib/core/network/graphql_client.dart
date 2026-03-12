// lib/core/network/graphql_client.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

/// Configuración del cliente GraphQL
/// Se usa Open Meteo a través de una API GraphQL pública de clima
/// Endpoint: https://graphql-weather-api.herokuapp.com/  (si no disponible, usar mock)
class GraphQLConfig {
  GraphQLConfig._();

  // Endpoint GraphQL público de clima (GraphQL Weather API)
  static const String weatherGraphQLEndpoint =
      'https://graphql-weather-api.herokuapp.com/';

  static GraphQLClient get client {
    final HttpLink httpLink = HttpLink(
      weatherGraphQLEndpoint,
      defaultHeaders: {
        'Content-Type': 'application/json',
      },
    );

    // Manejo de errores a nivel de enlace
    final ErrorLink errorLink = ErrorLink(
      onGraphQLError: (request, forward, response) async* {
        print('[GraphQL Error] ${response.errors}');
        yield* forward(request);
      },
      onException: (request, forward, exception) async* {
        print('[GraphQL Exception] $exception');
        yield* forward(request);
      },
    );

    final Link link = errorLink.concat(httpLink);

    return GraphQLClient(
      link: link,
      cache: GraphQLCache(
        store: InMemoryStore(),
      ),
      defaultPolicies: DefaultPolicies(
        query: Policies(
          fetch: FetchPolicy.cacheAndNetwork,
        ),
      ),
    );
  }

  static ValueNotifier<GraphQLClient> get clientNotifier =>
      ValueNotifier<GraphQLClient>(client);
}

/// Queries GraphQL para clima
class WeatherQueries {
  WeatherQueries._();

  /// Query para obtener clima actual por ciudad
  static const String getCurrentWeather = r'''
    query GetCityByName($name: String!, $country: String, $config: ConfigInput) {
      getCityByName(name: $name, country: $country, config: $config) {
        id
        name
        country
        coord {
          lon
          lat
        }
        weather {
          summary {
            title
            description
            icon
          }
          temperature {
            actual
            feelsLike
            min
            max
          }
          wind {
            speed
            deg
          }
          clouds {
            all
            visibility
            humidity
          }
          timestamp
        }
      }
    }
  ''';

  /// Query para obtener clima por coordenadas
  static const String getWeatherByCoords = r'''
    query GetCityByCoordinates($lat: Float!, $lon: Float!, $config: ConfigInput) {
      getCityByCoordinates(lat: $lat, lon: $lon, config: $config) {
        id
        name
        country
        weather {
          summary {
            title
            description
            icon
          }
          temperature {
            actual
            feelsLike
            min
            max
          }
          wind {
            speed
            deg
          }
          clouds {
            all
            visibility
            humidity
          }
          timestamp
        }
      }
    }
  ''';
}
