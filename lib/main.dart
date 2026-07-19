import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/location/location_service.dart';
import 'core/network/api_client.dart';
import 'data/weather_repository.dart';
import 'presentation/provider/settings_provider.dart';
import 'presentation/provider/weather_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final apiClient = ApiClient();
  final weatherRepository = WeatherRepositoryImpl(apiClient: apiClient);
  final locationService = LocationService();

  runApp(
    MultiProvider(
      providers: [
        Provider<WeatherRepository>.value(value: weatherRepository),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(preferences: preferences),
        ),
        ChangeNotifierProxyProvider<SettingsProvider, WeatherProvider>(
          create: (context) => WeatherProvider(
            repository: weatherRepository,
            locationService: locationService,
            preferences: preferences,
            settings: context.read<SettingsProvider>(),
          ),
          update: (_, settings, previous) => previous!..updateSettings(settings),
        ),
      ],
      child: const WeatherApp(),
    ),
  );
}
