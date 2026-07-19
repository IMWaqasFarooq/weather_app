import 'package:flutter/material.dart';

import '../../core/constants/enums.dart';
import '../../core/utils/weather_code_mapper.dart';
import '../../data/models/city.dart';
import '../../data/models/weather.dart';
import 'weather_icon.dart';

// Hero card showing location name and current conditions.
class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({
    super.key,
    required this.city,
    required this.current,
    required this.temperatureUnit,
    required this.windSpeedUnit,
  });

  final City city;
  final CurrentWeather current;
  final TemperatureUnit temperatureUnit;
  final WindSpeedUnit windSpeedUnit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              city.displayName,
              style: theme.textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                WeatherIcon(
                    code: current.weatherCode, isDay: current.isDay, size: 56),
                const SizedBox(width: 16),
                Text(
                  '${current.temperature.round()}${temperatureUnit.label}',
                  style: theme.textTheme.displaySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              WeatherCodeMapper.description(current.weatherCode),
              style: theme.textTheme.bodyLarge,
            ),
            Text(
              'Feels like ${current.apparentTemperature.round()}${temperatureUnit.label}',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Metric(
                    icon: Icons.water_drop_outlined,
                    label: '${current.humidity}%',
                    caption: 'Humidity'),
                _Metric(
                  icon: Icons.air,
                  label: '${current.windSpeed.round()} ${windSpeedUnit.label}',
                  caption: 'Wind',
                ),
                _Metric(
                  icon: Icons.umbrella_outlined,
                  label: '${current.precipitation.toStringAsFixed(1)} mm',
                  caption: 'Precip.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(
      {required this.icon, required this.label, required this.caption});

  final IconData icon;
  final String label;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 6),
        Text(label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        Text(caption,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline)),
      ],
    );
  }
}
