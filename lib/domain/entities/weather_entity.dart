// lib/domain/entities/weather_entity.dart
import 'package:equatable/equatable.dart';

class WeatherEntity extends Equatable {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final int windDegrees;
  final int pressure;
  final int cloudiness;
  final int visibility;
  final String weatherTitle;
  final String weatherDescription;
  final String weatherIcon;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final DateTime? sunrise;
  final DateTime? sunset;
  final String dataSource; // 'REST' o 'GraphQL'

  const WeatherEntity({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.windDegrees,
    required this.pressure,
    required this.cloudiness,
    required this.visibility,
    required this.weatherTitle,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.sunrise,
    this.sunset,
    required this.dataSource,
  });

  String get iconUrl =>
      'https://openweathermap.org/img/wn/${weatherIcon}@2x.png';

  String get formattedTemperature => '${temperature.round()}°C';
  String get formattedFeelsLike => '${feelsLike.round()}°C';
  String get formattedWindSpeed => '${windSpeed.toStringAsFixed(1)} km/h';
  String get formattedHumidity => '$humidity%';
  String get formattedPressure => '$pressure hPa';

  @override
  List<Object?> get props => [cityName, country, timestamp, dataSource];
}

// lib/domain/entities/forecast_entity.dart
class ForecastEntity extends Equatable {
  final DateTime dateTime;
  final double temperature;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final String weatherTitle;
  final String weatherDescription;
  final String weatherIcon;
  final double precipitationProbability;
  final String dataSource;

  const ForecastEntity({
    required this.dateTime,
    required this.temperature,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.weatherTitle,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.precipitationProbability,
    required this.dataSource,
  });

  String get formattedTemp => '${temperature.round()}°';
  String get formattedMinMax =>
      '${tempMin.round()}° / ${tempMax.round()}°';

  @override
  List<Object?> get props => [dateTime, dataSource];
}

// lib/domain/entities/air_quality_entity.dart
class AirQualityEntity extends Equatable {
  final int aqi;          // Air Quality Index (1-5)
  final double co;        // Carbon Monoxide
  final double no2;       // Nitrogen Dioxide
  final double o3;        // Ozone
  final double pm25;      // PM2.5
  final double pm10;      // PM10
  final DateTime timestamp;

  const AirQualityEntity({
    required this.aqi,
    required this.co,
    required this.no2,
    required this.o3,
    required this.pm25,
    required this.pm10,
    required this.timestamp,
  });

  String get aqiLabel {
    switch (aqi) {
      case 1: return 'Buena';
      case 2: return 'Aceptable';
      case 3: return 'Moderada';
      case 4: return 'Deficiente';
      case 5: return 'Muy deficiente';
      default: return 'Desconocida';
    }
  }

  int get aqiColor {
    switch (aqi) {
      case 1: return 0xFF4CAF50;
      case 2: return 0xFF8BC34A;
      case 3: return 0xFFFF9800;
      case 4: return 0xFFF44336;
      case 5: return 0xFF9C27B0;
      default: return 0xFF9E9E9E;
    }
  }

  @override
  List<Object?> get props => [aqi, timestamp];
}
