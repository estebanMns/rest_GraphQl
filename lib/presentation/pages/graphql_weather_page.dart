// lib/presentation/pages/graphql_weather_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_theme.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_widgets.dart';

class GraphQLWeatherPage extends ConsumerStatefulWidget {
  const GraphQLWeatherPage({super.key});

  @override
  ConsumerState<GraphQLWeatherPage> createState() =>
      _GraphQLWeatherPageState();
}

class _GraphQLWeatherPageState extends ConsumerState<GraphQLWeatherPage> {
  String _selectedCity = 'Bogotá';
  String _selectedCountry = 'CO';

  // Ciudades de prueba para demostración
  static const List<Map<String, String>> _demoCities = [
    {'city': 'Bogotá', 'country': 'CO'},
    {'city': 'Medellín', 'country': 'CO'},
    {'city': 'Madrid', 'country': 'ES'},
    {'city': 'Paris', 'country': 'FR'},
    {'city': 'London', 'country': 'GB'},
    {'city': 'New York', 'country': 'US'},
    {'city': 'Tokyo', 'country': 'JP'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(weatherGraphQLProvider.notifier)
          .fetchWeatherGraphQL('Bogotá', country: 'CO');
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherGraphQLProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Banner GraphQL
          _GraphQLInfoBanner(),
          const SizedBox(height: 16),

          // Búsqueda manual
          WeatherSearchBar(
            initialValue: _selectedCity,
            onSearch: (city) {
              setState(() => _selectedCity = city);
              ref
                  .read(weatherGraphQLProvider.notifier)
                  .fetchWeatherGraphQL(city);
            },
          ),
          const SizedBox(height: 12),

          // Selector de ciudades demo
          _CityChips(
            cities: _demoCities,
            selectedCity: _selectedCity,
            onCitySelected: (city, country) {
              setState(() {
                _selectedCity = city;
                _selectedCountry = country;
              });
              ref
                  .read(weatherGraphQLProvider.notifier)
                  .fetchWeatherGraphQL(city, country: country);
            },
          ),
          const SizedBox(height: 12),

          // Contenido
          Expanded(
            child: _buildContent(state),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(WeatherState state) {
    if (state.isLoading) {
      return const SingleChildScrollView(child: WeatherShimmer());
    }

    if (state.hasError) {
      return WeatherErrorWidget(
        message: state.errorMessage ?? 'Error al consultar GraphQL',
        onRetry: () => ref
            .read(weatherGraphQLProvider.notifier)
            .fetchWeatherGraphQL(_selectedCity, country: _selectedCountry),
      );
    }

    if (!state.hasData) {
      return const _GraphQLEmptyState();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta principal
          MainWeatherCard(weather: state.weather!),
          const SizedBox(height: 16),

          // Detalles
          WeatherDetailsGrid(weather: state.weather!),
          const SizedBox(height: 16),

          // Query GraphQL mostrada al usuario
          _GraphQLQueryViewer(cityName: _selectedCity, country: _selectedCountry),
          const SizedBox(height: 16),

          // Info técnica GraphQL
          _GraphQLTechnicalInfo(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _GraphQLInfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE91E63).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.hub, color: Color(0xFFE91E63), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GraphQL Weather API',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'query getCityByName { weather { temperature { actual } } }',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CityChips extends StatelessWidget {
  final List<Map<String, String>> cities;
  final String selectedCity;
  final Function(String city, String country) onCitySelected;

  const _CityChips({
    required this.cities,
    required this.selectedCity,
    required this.onCitySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cities.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = cities[i];
          final isSelected = c['city'] == selectedCity;
          return GestureDetector(
            onTap: () => onCitySelected(c['city']!, c['country']!),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE91E63)
                    : AppColors.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFE91E63)
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Text(
                c['city']!,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GraphQLQueryViewer extends StatelessWidget {
  final String cityName;
  final String country;
  const _GraphQLQueryViewer(
      {required this.cityName, required this.country});

  @override
  Widget build(BuildContext context) {
    final query = '''query {
  getCityByName(
    name: "$cityName",
    country: "$country",
    config: { units: metric, lang: es }
  ) {
    name
    country
    weather {
      summary { title description icon }
      temperature { actual feelsLike min max }
      wind { speed deg }
      clouds { humidity all visibility }
    }
  }
}''';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.data_object,
                    color: Color(0xFFE91E63), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Query Ejecutada',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                query,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Color(0xFF79C0FF),
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GraphQLTechnicalInfo extends StatelessWidget {
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
                const Icon(Icons.hub, color: Color(0xFFE91E63)),
                const SizedBox(width: 8),
                Text(
                  'Implementación GraphQL',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.backgroundLight),
            const SizedBox(height: 8),
            _CodeLine(label: 'Librería', value: 'graphql_flutter ^5.1.2'),
            _CodeLine(label: 'Operación', value: 'Query (getCityByName)'),
            _CodeLine(label: 'Fetch Policy', value: 'NetworkOnly'),
            _CodeLine(label: 'Cache', value: 'InMemoryStore'),
            _CodeLine(
                label: 'Error Link', value: 'GraphQL + Network errors'),
            _CodeLine(label: 'Tipado', value: 'WeatherGraphQLModel'),
          ],
        ),
      ),
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
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFE91E63),
              fontSize: 13,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _GraphQLEmptyState extends StatelessWidget {
  const _GraphQLEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hub_outlined, size: 80, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text(
            'Selecciona una ciudad\npara consultar via GraphQL',
            style:
                TextStyle(color: AppColors.textSecondary, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
