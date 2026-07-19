import 'package:flutter/material.dart';

import '../../core/constants/enums.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/weather.dart';
import 'weather_icon.dart';

/// Horizontally scrolling list of the next 24 hours of forecast, starting
/// from the current hour.
class HourlyForecastList extends StatelessWidget {
  const HourlyForecastList({
    super.key,
    required this.hourly,
    required this.temperatureUnit,
  });

  final List<HourlyWeather> hourly;
  final TemperatureUnit temperatureUnit;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming = hourly.where((h) => h.time.isAfter(now.subtract(const Duration(minutes: 1)))).take(24).toList();

    if (upcoming.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Hourly forecast', style: Theme.of(context).textTheme.titleSmall),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: upcoming.length,
                separatorBuilder: (_, __) => const SizedBox(width: 20),
                itemBuilder: (context, index) {
                  final hour = upcoming[index];
                  final label = index == 0 ? 'Now' : DateFormatter.hour(hour.time);
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 8),
                      WeatherIcon(code: hour.weatherCode, size: 24),
                      const SizedBox(height: 8),
                      Text(
                        '${hour.temperature.round()}${temperatureUnit.label}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
