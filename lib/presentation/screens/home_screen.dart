import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/enums.dart';
import '../provider/settings_provider.dart';
import '../provider/weather_provider.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/daily_forecast_list.dart';
import '../widgets/error_view.dart';
import '../widgets/hourly_forecast_list.dart';
import '../widgets/loading_view.dart';
import '../widgets/recent_cities_list.dart';
import 'city_search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().loadInitialWeather();
    });
  }

  Future<void> _openSearch() async {
    final city = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(builder: (_) => const CitySearchScreen()),
    );
    if (city != null && mounted) {
      await context.read<WeatherProvider>().selectCity(city);
    }
  }

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        actions: [
          IconButton(
            tooltip: 'Use current location',
            icon: const Icon(Icons.my_location),
            onPressed: () => context.read<WeatherProvider>().useCurrentLocation(),
          ),
          IconButton(
            tooltip: 'Search city',
            icon: const Icon(Icons.search),
            onPressed: _openSearch,
          ),
          IconButton(
            tooltip: 'Toggle °C/°F',
            onPressed: () => context.read<SettingsProvider>().toggleTemperatureUnit(),
            icon: Text(
              settings.temperatureUnit == TemperatureUnit.celsius ? '°F' : '°C',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              context.read<SettingsProvider>().setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
            },
          ),
        ],
      ),
      body: SafeArea(child: _buildBody(context, weather, settings)),
    );
  }

  Widget _buildBody(BuildContext context, WeatherProvider weather, SettingsProvider settings) {
    switch (weather.status) {
      case ViewStatus.initial:
        return ErrorView(
          icon: Icons.wb_sunny_outlined,
          message: 'Search for a city or use your current location to see the weather.',
          onRetry: () => weather.useCurrentLocation(),
          retryLabel: 'Use current location',
        );
      case ViewStatus.loading:
        return const LoadingView(message: 'Fetching weather…');
      case ViewStatus.error:
        return ErrorView(
          message: weather.failure?.message ?? 'Something went wrong.',
          onRetry: () {
            if (weather.isUsingCurrentLocation) {
              weather.useCurrentLocation();
            } else if (weather.city != null) {
              weather.selectCity(weather.city!);
            } else {
              weather.loadInitialWeather();
            }
          },
        );
      case ViewStatus.success:
      case ViewStatus.refreshing:
        final report = weather.report;
        final city = weather.city;
        if (report == null || city == null) return const LoadingView();

        return RefreshIndicator(
          onRefresh: weather.refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (weather.recentCities.isNotEmpty) ...[
                RecentCitiesList(
                  cities: weather.recentCities,
                  selectedCity: city,
                  onSelected: (c) => weather.selectCity(c),
                ),
                const SizedBox(height: 16),
              ],
              CurrentWeatherCard(
                city: city,
                current: report.current,
                temperatureUnit: settings.temperatureUnit,
                windSpeedUnit: settings.windSpeedUnit,
              ),
              const SizedBox(height: 16),
              HourlyForecastList(hourly: report.hourly, temperatureUnit: settings.temperatureUnit),
              const SizedBox(height: 16),
              DailyForecastList(daily: report.daily, temperatureUnit: settings.temperatureUnit),
            ],
          ),
        );
    }
  }
}
