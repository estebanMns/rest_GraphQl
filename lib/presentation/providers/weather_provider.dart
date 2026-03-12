// lib/presentation/providers/weather_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../core/network/api_client.dart';
import '../../core/network/graphql_client.dart';
import '../../data/datasources/weather_graphql_datasource.dart';
import '../../data/datasources/weather_remote_datasource.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/usecases/get_current_weather.dart';

// ── Estado ────────────────────────────────────────────────────────

enum WeatherStatus { initial, loading, success, error }

class WeatherState {
  final WeatherStatus status;
  final WeatherEntity? weather;
  final List<ForecastEntity> forecast;
  final AirQualityEntity? airQuality;
  final String? errorMessage;
  final String currentCity;
  final String dataSource; // 'REST' o 'GraphQL'

  const WeatherState({
    this.status = WeatherStatus.initial,
    this.weather,
    this.forecast = const [],
    this.airQuality,
    this.errorMessage,
    this.currentCity = 'Bogotá',
    this.dataSource = 'REST',
  });

  bool get isLoading => status == WeatherStatus.loading;
  bool get hasData => status == WeatherStatus.success && weather != null;
  bool get hasError => status == WeatherStatus.error;

  WeatherState copyWith({
    WeatherStatus? status,
    WeatherEntity? weather,
    List<ForecastEntity>? forecast,
    AirQualityEntity? airQuality,
    String? errorMessage,
    String? currentCity,
    String? dataSource,
  }) {
    return WeatherState(
      status: status ?? this.status,
      weather: weather ?? this.weather,
      forecast: forecast ?? this.forecast,
      airQuality: airQuality ?? this.airQuality,
      errorMessage: errorMessage,
      currentCity: currentCity ?? this.currentCity,
      dataSource: dataSource ?? this.dataSource,
    );
  }
}

// ── Dependencias (DI manual) ──────────────────────────────────────

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final graphqlClientProvider = Provider<GraphQLClient>(
    (ref) => GraphQLConfig.client);

final weatherDataSourceProvider = Provider<WeatherRemoteDataSource>((ref) {
  return WeatherRemoteDataSourceImpl(
      apiClient: ref.watch(apiClientProvider));
});

final graphqlDataSourceProvider = Provider<WeatherGraphQLDataSource>((ref) {
  return WeatherGraphQLDataSourceImpl(
      client: ref.watch(graphqlClientProvider));
});

final weatherRepositoryProvider = Provider<WeatherRepositoryImpl>((ref) {
  return WeatherRepositoryImpl(
      remoteDataSource: ref.watch(weatherDataSourceProvider));
});

final graphqlRepositoryProvider =
    Provider<WeatherGraphQLRepositoryImpl>((ref) {
  return WeatherGraphQLRepositoryImpl(
      graphqlDataSource: ref.watch(graphqlDataSourceProvider));
});

// Use cases
final getCurrentWeatherUseCaseProvider =
    Provider<GetCurrentWeatherByCityUseCase>((ref) {
  return GetCurrentWeatherByCityUseCase(
      ref.watch(weatherRepositoryProvider));
});

final getForecastUseCaseProvider =
    Provider<GetForecastByCityUseCase>((ref) {
  return GetForecastByCityUseCase(ref.watch(weatherRepositoryProvider));
});

final getAirQualityUseCaseProvider =
    Provider<GetAirQualityUseCase>((ref) {
  return GetAirQualityUseCase(ref.watch(weatherRepositoryProvider));
});

final getWeatherGraphQLUseCaseProvider =
    Provider<GetCurrentWeatherGraphQLUseCase>((ref) {
  return GetCurrentWeatherGraphQLUseCase(
      ref.watch(graphqlRepositoryProvider));
});

// ── Notifiers ─────────────────────────────────────────────────────

/// Provider REST
class WeatherNotifier extends StateNotifier<WeatherState> {
  final GetCurrentWeatherByCityUseCase _getCurrentWeather;
  final GetForecastByCityUseCase _getForecast;
  final GetAirQualityUseCase _getAirQuality;

  WeatherNotifier({
    required GetCurrentWeatherByCityUseCase getCurrentWeather,
    required GetForecastByCityUseCase getForecast,
    required GetAirQualityUseCase getAirQuality,
  })  : _getCurrentWeather = getCurrentWeather,
        _getForecast = getForecast,
        _getAirQuality = getAirQuality,
        super(const WeatherState());

  Future<void> fetchWeather(String cityName) async {
    state = state.copyWith(
      status: WeatherStatus.loading,
      currentCity: cityName,
      dataSource: 'REST',
    );

    final weatherResult = await _getCurrentWeather(
        CityParams(cityName: cityName));

    weatherResult.fold(
      (failure) => state = state.copyWith(
        status: WeatherStatus.error,
        errorMessage: failure.message,
      ),
      (weather) async {
        state = state.copyWith(
          status: WeatherStatus.success,
          weather: weather,
          dataSource: 'REST',
        );

        // Fetch forecast y calidad del aire en paralelo
        final results = await Future.wait([
          _getForecast(CityParams(cityName: cityName)),
          _getAirQuality(
              CoordsParams(lat: weather.latitude, lon: weather.longitude)),
        ]);

        results[0].fold(
          (_) {},
          (forecast) => state =
              state.copyWith(forecast: forecast as List<ForecastEntity>),
        );

        results[1].fold(
          (_) {},
          (airQuality) =>
              state = state.copyWith(airQuality: airQuality as AirQualityEntity),
        );
      },
    );
  }
}

/// Provider GraphQL
class WeatherGraphQLNotifier extends StateNotifier<WeatherState> {
  final GetCurrentWeatherGraphQLUseCase _getWeatherGraphQL;

  WeatherGraphQLNotifier({
    required GetCurrentWeatherGraphQLUseCase getWeatherGraphQL,
  })  : _getWeatherGraphQL = getWeatherGraphQL,
        super(const WeatherState());

  Future<void> fetchWeatherGraphQL(String cityName,
      {String? country}) async {
    state = state.copyWith(
      status: WeatherStatus.loading,
      currentCity: cityName,
      dataSource: 'GraphQL',
    );

    final result = await _getWeatherGraphQL(
      GraphQLCityParams(
        cityName: cityName,
        country: country,
        units: 'metric',
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: WeatherStatus.error,
        errorMessage: failure.message,
      ),
      (weather) => state = state.copyWith(
        status: WeatherStatus.success,
        weather: weather,
        dataSource: 'GraphQL',
      ),
    );
  }
}

// ── Providers finales ─────────────────────────────────────────────

final weatherProvider =
    StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  return WeatherNotifier(
    getCurrentWeather: ref.watch(getCurrentWeatherUseCaseProvider),
    getForecast: ref.watch(getForecastUseCaseProvider),
    getAirQuality: ref.watch(getAirQualityUseCaseProvider),
  );
});

final weatherGraphQLProvider =
    StateNotifierProvider<WeatherGraphQLNotifier, WeatherState>((ref) {
  return WeatherGraphQLNotifier(
    getWeatherGraphQL: ref.watch(getWeatherGraphQLUseCaseProvider),
  );
});

// Provider que expone el estado activo según la tab seleccionada
final activeTabProvider = StateProvider<int>((ref) => 0);

final activeWeatherProvider = Provider<WeatherState>((ref) {
  final tab = ref.watch(activeTabProvider);
  return tab == 0
      ? ref.watch(weatherProvider)
      : ref.watch(weatherGraphQLProvider);
});
