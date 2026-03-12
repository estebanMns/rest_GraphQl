// lib/presentation/widgets/weather_widgets.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_theme.dart';
import '../../domain/entities/weather_entity.dart';

// ── Badge de fuente de datos ───────────────────────────────────────

class DataSourceBadge extends StatelessWidget {
  final String source;
  const DataSourceBadge({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    final isGraphQL = source == 'GraphQL';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGraphQL
              ? [const Color(0xFFE91E63), const Color(0xFF9C27B0)]
              : [const Color(0xFF1565C0), const Color(0xFF00BCD4)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGraphQL ? Icons.hub : Icons.api,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            source,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta principal de clima ────────────────────────────────────

class MainWeatherCard extends StatelessWidget {
  final WeatherEntity weather;
  const MainWeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.skyGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ciudad y fuente
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.cityName,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Text(
                    weather.country,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              DataSourceBadge(source: weather.dataSource),
            ],
          ),
          const SizedBox(height: 24),

          // Temperatura y ícono
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.formattedTemperature,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  Text(
                    weather.weatherDescription.toUpperCase(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          letterSpacing: 1.2,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sensación ${weather.formattedFeelsLike}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
              Image.network(
                weather.iconUrl,
                width: 80,
                height: 80,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.wb_sunny,
                  size: 80,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Rango temperatura
          Row(
            children: [
              _TempTag(label: 'Máx', temp: '${weather.tempMax.round()}°'),
              const SizedBox(width: 12),
              _TempTag(label: 'Mín', temp: '${weather.tempMin.round()}°'),
              const Spacer(),
              Text(
                DateFormat('HH:mm').format(weather.timestamp),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TempTag extends StatelessWidget {
  final String label;
  final String temp;
  const _TempTag({required this.label, required this.temp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label $temp',
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}

// ── Grid de detalles ──────────────────────────────────────────────

class WeatherDetailsGrid extends StatelessWidget {
  final WeatherEntity weather;
  const WeatherDetailsGrid({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: [
        _DetailTile(
          icon: Icons.water_drop_outlined,
          label: 'Humedad',
          value: weather.formattedHumidity,
          color: Colors.blue,
        ),
        _DetailTile(
          icon: Icons.air,
          label: 'Viento',
          value: weather.formattedWindSpeed,
          color: Colors.cyan,
        ),
        _DetailTile(
          icon: Icons.compress,
          label: 'Presión',
          value: weather.formattedPressure,
          color: Colors.purple,
        ),
        _DetailTile(
          icon: Icons.visibility_outlined,
          label: 'Visibilidad',
          value: '${(weather.visibility / 1000).toStringAsFixed(1)} km',
          color: Colors.teal,
        ),
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 16,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pronóstico horizontal ─────────────────────────────────────────

class HourlyForecastList extends StatelessWidget {
  final List<ForecastEntity> forecasts;
  const HourlyForecastList({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    final hourly = forecasts.take(8).toList();
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hourly.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final item = hourly[i];
          return Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  DateFormat('HH:mm').format(item.dateTime),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Image.network(
                  'https://openweathermap.org/img/wn/${item.weatherIcon}.png',
                  width: 36,
                  height: 36,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.wb_cloudy, size: 28, color: Colors.grey),
                ),
                Text(
                  item.formattedTemp,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Pronóstico diario ─────────────────────────────────────────────

class DailyForecastList extends StatelessWidget {
  final List<ForecastEntity> forecasts;
  const DailyForecastList({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    // Agrupar por día (tomar 1 por día)
    final Map<String, ForecastEntity> dailyMap = {};
    for (final f in forecasts) {
      final key = DateFormat('yyyy-MM-dd').format(f.dateTime);
      if (!dailyMap.containsKey(key)) {
        dailyMap[key] = f;
      }
    }
    final daily = dailyMap.values.take(5).toList();

    return Column(
      children: daily.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  DateFormat('E dd/MM', 'es').format(item.dateTime),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Image.network(
                'https://openweathermap.org/img/wn/${item.weatherIcon}.png',
                width: 36,
                height: 36,
                errorBuilder: (_, __, ___) => const Icon(Icons.wb_cloudy,
                    size: 28, color: Colors.grey),
              ),
              const Spacer(),
              if (item.precipitationProbability > 0)
                Row(
                  children: [
                    const Icon(Icons.water_drop,
                        size: 14, color: Colors.blue),
                    const SizedBox(width: 2),
                    Text(
                      '${item.precipitationProbability.round()}%',
                      style: const TextStyle(
                          color: Colors.blue, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              Text(
                item.formattedMinMax,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Calidad del aire ──────────────────────────────────────────────

class AirQualityCard extends StatelessWidget {
  final AirQualityEntity airQuality;
  const AirQualityCard({super.key, required this.airQuality});

  @override
  Widget build(BuildContext context) {
    final color = Color(airQuality.aqiColor);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.air, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Calidad del Aire',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    airQuality.aqiLabel,
                    style: TextStyle(
                        color: color, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AqiItem(label: 'PM2.5', value: airQuality.pm25),
                _AqiItem(label: 'PM10', value: airQuality.pm10),
                _AqiItem(label: 'O₃', value: airQuality.o3),
                _AqiItem(label: 'NO₂', value: airQuality.no2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AqiItem extends StatelessWidget {
  final String label;
  final double value;
  const _AqiItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toStringAsFixed(1),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }
}

// ── Shimmer loading ───────────────────────────────────────────────

class WeatherShimmer extends StatelessWidget {
  const WeatherShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ShimmerBox(height: 220, borderRadius: 24),
        const SizedBox(height: 16),
        _ShimmerBox(height: 120, borderRadius: 16),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _ShimmerBox(height: 80, borderRadius: 12)),
            const SizedBox(width: 12),
            Expanded(child: _ShimmerBox(height: 80, borderRadius: 12)),
          ],
        ),
      ],
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double height;
  final double borderRadius;
  const _ShimmerBox({required this.height, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// ── Error widget ──────────────────────────────────────────────────

class WeatherErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const WeatherErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 80, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Intentar de nuevo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────

class WeatherSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String initialValue;

  const WeatherSearchBar({
    super.key,
    required this.onSearch,
    this.initialValue = '',
  });

  @override
  State<WeatherSearchBar> createState() => _WeatherSearchBarState();
}

class _WeatherSearchBarState extends State<WeatherSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Buscar ciudad...',
        prefixIcon:
            const Icon(Icons.search, color: AppColors.textSecondary),
        suffixIcon: IconButton(
          icon: const Icon(Icons.send, color: AppColors.primaryLight),
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              widget.onSearch(_controller.text.trim());
            }
          },
        ),
      ),
      textInputAction: TextInputAction.search,
      onSubmitted: (value) {
        if (value.trim().isNotEmpty) {
          widget.onSearch(value.trim());
        }
      },
    );
  }
}
