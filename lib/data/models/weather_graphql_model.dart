// lib/data/models/weather_graphql_model.dart
import '../../domain/entities/weather_entity.dart';

/// Modelo para la respuesta GraphQL de getCityByName
class WeatherGraphQLModel {
  final String? id;
  final String cityName;
  final String? country;
  final double? lat;
  final double? lon;
  final String? weatherTitle;
  final String? weatherDescription;
  final String? weatherIcon;
  final double? temperature;
  final double? feelsLike;
  final double? tempMin;
  final double? tempMax;
  final double? windSpeed;
  final int? windDeg;
  final int? humidity;
  final int? cloudiness;
  final int? visibility;
  final int? timestamp;

  const WeatherGraphQLModel({
    this.id,
    required this.cityName,
    this.country,
    this.lat,
    this.lon,
    this.weatherTitle,
    this.weatherDescription,
    this.weatherIcon,
    this.temperature,
    this.feelsLike,
    this.tempMin,
    this.tempMax,
    this.windSpeed,
    this.windDeg,
    this.humidity,
    this.cloudiness,
    this.visibility,
    this.timestamp,
  });

  factory WeatherGraphQLModel.fromGraphQL(Map<String, dynamic> json) {
    final weather = json['weather'] as Map<String, dynamic>?;
    final summary = weather?['summary'] as Map<String, dynamic>?;
    final tempData = weather?['temperature'] as Map<String, dynamic>?;
    final wind = weather?['wind'] as Map<String, dynamic>?;
    final clouds = weather?['clouds'] as Map<String, dynamic>?;
    final coord = json['coord'] as Map<String, dynamic>?;

    return WeatherGraphQLModel(
      id: json['id'] as String?,
      cityName: json['name'] as String? ?? 'Unknown',
      country: json['country'] as String?,
      lat: (coord?['lat'] as num?)?.toDouble(),
      lon: (coord?['lon'] as num?)?.toDouble(),
      weatherTitle: summary?['title'] as String?,
      weatherDescription: summary?['description'] as String?,
      weatherIcon: summary?['icon'] as String?,
      temperature: (tempData?['actual'] as num?)?.toDouble(),
      feelsLike: (tempData?['feelsLike'] as num?)?.toDouble(),
      tempMin: (tempData?['min'] as num?)?.toDouble(),
      tempMax: (tempData?['max'] as num?)?.toDouble(),
      windSpeed: (wind?['speed'] as num?)?.toDouble(),
      windDeg: (wind?['deg'] as num?)?.toInt(),
      humidity: (clouds?['humidity'] as num?)?.toInt(),
      cloudiness: (clouds?['all'] as num?)?.toInt(),
      visibility: (clouds?['visibility'] as num?)?.toInt(),
      timestamp: weather?['timestamp'] as int?,
    );
  }

  WeatherEntity toEntity() {
    final ts = timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000)
        : DateTime.now();

    return WeatherEntity(
      cityName: cityName,
      country: country ?? '',
      temperature: temperature ?? 0,
      feelsLike: feelsLike ?? 0,
      tempMin: tempMin ?? 0,
      tempMax: tempMax ?? 0,
      humidity: humidity ?? 0,
      windSpeed: (windSpeed ?? 0) * 3.6,
      windDegrees: windDeg ?? 0,
      pressure: 0,
      cloudiness: cloudiness ?? 0,
      visibility: visibility ?? 10000,
      weatherTitle: weatherTitle ?? '',
      weatherDescription: weatherDescription ?? '',
      weatherIcon: weatherIcon ?? '01d',
      timestamp: ts,
      latitude: lat ?? 0,
      longitude: lon ?? 0,
      dataSource: 'GraphQL',
    );
  }
}
