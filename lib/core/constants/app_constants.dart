// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  // API
  static const String openWeatherBaseUrl =
      'https://api.openweathermap.org/data/2.5';
  static const String openWeatherApiKey =
      'YOUR_OPENWEATHER_API_KEY'; // Reemplazar con variable de entorno

  // GraphQL - WeatherAPI via GraphQL wrapper (Open Meteo GraphQL)
  static const String graphqlEndpoint =
      'https://graphqlzero.almansi.me/api';

  // Open Meteo (GraphQL-like REST, free & no key needed)
  static const String openMeteoBase = 'https://api.open-meteo.com/v1';

  // App
  static const String appName = 'WeatherApp';
  static const String defaultCity = 'Bogotá';
  static const String defaultCountry = 'CO';

  // Cache duration
  static const Duration cacheDuration = Duration(minutes: 30);

  // Weather Icons base
  static const String weatherIconBase =
      'https://openweathermap.org/img/wn/';
}

class ApiEndpoints {
  ApiEndpoints._();

  static const String currentWeather = '/weather';
  static const String forecast = '/forecast';
  static const String airQuality = '/air_pollution';
}

class AppStrings {
  AppStrings._();

  static const String appTitle = 'Weather App';
  static const String restTabLabel = 'REST API';
  static const String graphqlTabLabel = 'GraphQL';
  static const String searchHint = 'Buscar ciudad...';
  static const String loading = 'Cargando datos...';
  static const String errorGeneric = 'Ocurrió un error. Intenta de nuevo.';
  static const String errorNoInternet = 'Sin conexión a internet.';
  static const String errorCityNotFound = 'Ciudad no encontrada.';
  static const String feelsLike = 'Sensación';
  static const String humidity = 'Humedad';
  static const String wind = 'Viento';
  static const String pressure = 'Presión';
  static const String forecast5Days = 'Pronóstico 5 días';
  static const String hourlyForecast = 'Pronóstico por hora';
  static const String airQualityLabel = 'Calidad del aire';
}
