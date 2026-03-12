// lib/presentation/pages/rest_weather_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_theme.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_widgets.dart';

class RestWeatherPage extends ConsumerStatefulWidget {
  const RestWeatherPage({super.key});

  @override
  ConsumerState<RestWeatherPage> createState() => _RestWeatherPageState();
}

class _RestWeatherPageState extends ConsumerState<RestWeatherPage> {
  @override
  void initState() {
    super.initState();
    // Cargar ciudad por defecto al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(weatherProvider.notifier).fetchWeather('Bogotá');
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Header con info de API
          _RestApiInfoBanner(),
          const SizedBox(height: 16),

          // Buscador
          WeatherSearchBar(
            initialValue: state.currentCity,
            onSearch: (city) =>
                ref.read(weatherProvider.notifier).fetchWeather(city),
          ),
          const SizedBox(height: 16),

          // Contenido
          Expanded(
            child: _buildContent(state, context),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(WeatherState state, BuildContext context) {
    if (state.isLoading) {
      return const SingleChildScrollView(child: WeatherShimmer());
    }

    if (state.hasError) {
      return WeatherErrorWidget(
        message: state.errorMessage ?? 'Error desconocido',
        onRetry: () => ref
            .read(weatherProvider.notifier)
            .fetchWeather(state.currentCity),
      );
    }

    if (!state.hasData) {
      return _EmptyState(
        onSearch: (city) =>
            ref.read(weatherProvider.notifier).fetchWeather(city),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta principal
          MainWeatherCard(weather: state.weather!),
          const SizedBox(height: 16),

          // Grid de detalles
          WeatherDetailsGrid(weather: state.weather!),
          const SizedBox(height: 16),

          // Pronóstico horario
          if (state.forecast.isNotEmpty) ...[
            _SectionTitle(title: 'Pronóstico por Hora'),
            const SizedBox(height: 8),
            HourlyForecastList(forecasts: state.forecast),
            const SizedBox(height: 16),
          ],

          // Pronóstico diario
          if (state.forecast.isNotEmpty) ...[
            _SectionTitle(title: 'Próximos 5 Días'),
            const SizedBox(height: 8),
            DailyForecastList(forecasts: state.forecast),
            const SizedBox(height: 16),
          ],

          // Calidad del aire
          if (state.airQuality != null) ...[
            _SectionTitle(title: 'Calidad del Aire (AQI)'),
            const SizedBox(height: 8),
            AirQualityCard(airQuality: state.airQuality!),
            const SizedBox(height: 24),
          ],

          // Info técnica REST
          _RestTechnicalInfo(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _RestApiInfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.api, color: AppColors.primaryLight, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OpenWeatherMap REST API',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'GET /weather  •  GET /forecast  •  GET /air_pollution',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RestTechnicalInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.code, color: AppColors.primaryLight),
                const SizedBox(width: 8),
                Text(
                  'Implementación REST',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.backgroundLight),
            const SizedBox(height: 8),
            _CodeLine(
                label: 'Arquitectura', value: 'Clean Architecture'),
            _CodeLine(label: 'HTTP Client', value: 'Dio + Interceptors'),
            _CodeLine(label: 'State Mgmt', value: 'Riverpod (StateNotifier)'),
            _CodeLine(label: 'Patrón', value: 'Repository + UseCase'),
            _CodeLine(label: 'Error Handling', value: 'Either<Failure, T>'),
            _CodeLine(label: 'Endpoints', value: '3 (weather, forecast, AQI)'),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}

class _CodeLine extends StatelessWidget {
  final String label;
  final String value;
  const _CodeLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryLight,
              fontSize: 13,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Function(String) onSearch;
  const _EmptyState({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wb_sunny_outlined,
            size: 80,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          const Text(
            'Busca una ciudad para ver\nel clima actual',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
