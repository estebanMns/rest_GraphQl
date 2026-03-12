// lib/data/models/weather_model.dart
import '../../domain/entities/weather_entity.dart';

/// Modelo de respuesta de OpenWeatherMap REST API
class WeatherModel {
  final int id;
  final String cityName;
  final String country;
  final double latitude;
  final double longitude;
  final double temp;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int pressure;
  final int humidity;
  final int visibility;
  final double windSpeed;
  final int windDeg;
  final int clouds;
  final int weatherId;
  final String weatherMain;
  final String weatherDescription;
  final String weatherIcon;
  final int sunrise;
  final int sunset;
  final int dt;

  const WeatherModel({
    required this.id,
    required this.cityName,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    required this.visibility,
    required this.windSpeed,
    required this.windDeg,
    required this.clouds,
    required this.weatherId,
    required this.weatherMain,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.sunrise,
    required this.sunset,
    required this.dt,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0] as Map<String, dynamic>;
    final main = json['main'] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;
    final clouds = json['clouds'] as Map<String, dynamic>;
    final coord = json['coord'] as Map<String, dynamic>;
    final sys = json['sys'] as Map<String, dynamic>;

    return WeatherModel(
      id: json['id'] as int,
      cityName: json['name'] as String,
      country: sys['country'] as String,
      latitude: (coord['lat'] as num).toDouble(),
      longitude: (coord['lon'] as num).toDouble(),
      temp: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      tempMin: (main['temp_min'] as num).toDouble(),
      tempMax: (main['temp_max'] as num).toDouble(),
      pressure: main['pressure'] as int,
      humidity: main['humidity'] as int,
      visibility: (json['visibility'] as num? ?? 10000).toInt(),
      windSpeed: (wind['speed'] as num).toDouble(),
      windDeg: (wind['deg'] as num? ?? 0).toInt(),
      clouds: (clouds['all'] as num? ?? 0).toInt(),
      weatherId: weather['id'] as int,
      weatherMain: weather['main'] as String,
      weatherDescription: weather['description'] as String,
      weatherIcon: weather['icon'] as String,
      sunrise: sys['sunrise'] as int,
      sunset: sys['sunset'] as int,
      dt: json['dt'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': cityName,
      'sys': {'country': country, 'sunrise': sunrise, 'sunset': sunset},
      'coord': {'lat': latitude, 'lon': longitude},
      'main': {
        'temp': temp,
        'feels_like': feelsLike,
        'temp_min': tempMin,
        'temp_max': tempMax,
        'pressure': pressure,
        'humidity': humidity,
      },
      'visibility': visibility,
      'wind': {'speed': windSpeed, 'deg': windDeg},
      'clouds': {'all': clouds},
      'weather': [
        {
          'id': weatherId,
          'main': weatherMain,
          'description': weatherDescription,
          'icon': weatherIcon,
        }
      ],
      'dt': dt,
    };
  }

  /// Convierte el modelo de datos en entidad de dominio
  WeatherEntity toEntity() {
    return WeatherEntity(
      cityName: cityName,
      country: country,
      temperature: temp,
      feelsLike: feelsLike,
      tempMin: tempMin,
      tempMax: tempMax,
      humidity: humidity,
      windSpeed: windSpeed * 3.6, // m/s a km/h
      windDegrees: windDeg,
      pressure: pressure,
      cloudiness: clouds,
      visibility: visibility,
      weatherTitle: weatherMain,
      weatherDescription: weatherDescription,
      weatherIcon: weatherIcon,
      timestamp: DateTime.fromMillisecondsSinceEpoch(dt * 1000),
      latitude: latitude,
      longitude: longitude,
      sunrise: DateTime.fromMillisecondsSinceEpoch(sunrise * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(sunset * 1000),
      dataSource: 'REST',
    );
  }
}

/// Modelo para item del forecast (lista 3h)
class ForecastItemModel {
  final int dt;
  final double temp;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final String weatherMain;
  final String weatherDescription;
  final String weatherIcon;
  final double? pop; // probabilidad de precipitación

  const ForecastItemModel({
    required this.dt,
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.weatherMain,
    required this.weatherDescription,
    required this.weatherIcon,
    this.pop,
  });

  factory ForecastItemModel.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0] as Map<String, dynamic>;
    final main = json['main'] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;

    return ForecastItemModel(
      dt: json['dt'] as int,
      temp: (main['temp'] as num).toDouble(),
      tempMin: (main['temp_min'] as num).toDouble(),
      tempMax: (main['temp_max'] as num).toDouble(),
      humidity: main['humidity'] as int,
      windSpeed: (wind['speed'] as num).toDouble(),
      weatherMain: weather['main'] as String,
      weatherDescription: weather['description'] as String,
      weatherIcon: weather['icon'] as String,
      pop: (json['pop'] as num?)?.toDouble(),
    );
  }

  ForecastEntity toEntity() {
    return ForecastEntity(
      dateTime: DateTime.fromMillisecondsSinceEpoch(dt * 1000),
      temperature: temp,
      tempMin: tempMin,
      tempMax: tempMax,
      humidity: humidity,
      windSpeed: windSpeed * 3.6,
      weatherTitle: weatherMain,
      weatherDescription: weatherDescription,
      weatherIcon: weatherIcon,
      precipitationProbability: (pop ?? 0) * 100,
      dataSource: 'REST',
    );
  }
}

/// Modelo de calidad del aire
class AirQualityModel {
  final int aqi;
  final double co;
  final double no2;
  final double o3;
  final double pm25;
  final double pm10;
  final int dt;

  const AirQualityModel({
    required this.aqi,
    required this.co,
    required this.no2,
    required this.o3,
    required this.pm25,
    required this.pm10,
    required this.dt,
  });

  factory AirQualityModel.fromJson(Map<String, dynamic> json) {
    final list = json['list'][0] as Map<String, dynamic>;
    final components = list['components'] as Map<String, dynamic>;
    final mainAqi = list['main'] as Map<String, dynamic>;

    return AirQualityModel(
      aqi: mainAqi['aqi'] as int,
      co: (components['co'] as num).toDouble(),
      no2: (components['no2'] as num).toDouble(),
      o3: (components['o3'] as num).toDouble(),
      pm25: (components['pm2_5'] as num).toDouble(),
      pm10: (components['pm10'] as num).toDouble(),
      dt: list['dt'] as int,
    );
  }

  AirQualityEntity toEntity() {
    return AirQualityEntity(
      aqi: aqi,
      co: co,
      no2: no2,
      o3: o3,
      pm25: pm25,
      pm10: pm10,
      timestamp: DateTime.fromMillisecondsSinceEpoch(dt * 1000),
    );
  }
}
