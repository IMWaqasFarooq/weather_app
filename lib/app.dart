import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'presentation/provider/settings_provider.dart';
import 'presentation/screens/home_screen.dart';

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'Weather',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
