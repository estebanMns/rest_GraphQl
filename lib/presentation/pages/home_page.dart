// lib/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_theme.dart';
import '../providers/weather_provider.dart';
import 'rest_weather_page.dart';
import 'graphql_weather_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundDark,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: AppColors.skyGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.wb_sunny,
                    color: Colors.amber, size: 20),
              ),
              const SizedBox(width: 10),
              const Text('WeatherApp'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showAboutDialog(context),
              tooltip: 'Acerca de',
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                onTap: (index) =>
                    ref.read(activeTabProvider.notifier).state = index,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.api, size: 18),
                        SizedBox(width: 6),
                        Text('REST API',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hub, size: 18),
                        SizedBox(width: 6),
                        Text('GraphQL',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            RestWeatherPage(),
            GraphQLWeatherPage(),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('WeatherApp',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Taller: Integración con APIs\nProgramación Mobile con Flutter',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            SizedBox(height: 16),
            _InfoRow(label: 'REST API', value: 'OpenWeatherMap'),
            _InfoRow(label: 'GraphQL', value: 'GraphQL Weather API'),
            _InfoRow(label: 'Arquitectura', value: 'Clean Architecture'),
            _InfoRow(label: 'State Mgmt', value: 'Riverpod'),
            _InfoRow(label: 'HTTP Client', value: 'Dio'),
            _InfoRow(label: 'GraphQL Lib', value: 'graphql_flutter'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar',
                style: TextStyle(color: AppColors.primaryLight)),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 13)),
          ),
          Text(value,
              style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 13,
                  fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
