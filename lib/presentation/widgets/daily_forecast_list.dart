import 'package:flutter/material.dart';

import '../../core/constants/enums.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/weather.dart';
import 'weather_icon.dart';

/// Vertical list of the 7-day forecast, one row per day.
class DailyForecastList extends StatelessWidget {
  const DailyForecastList({
    super.key,
    required this.daily,
    required this.temperatureUnit,
  });

  final List<DailyWeather> daily;
  final TemperatureUnit temperatureUnit;

  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('7-day forecast', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            for (var i = 0; i < daily.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              _DailyRow(day: daily[i], temperatureUnit: temperatureUnit, isToday: i == 0),
            ],
          ],
        ),
      ),
    );
  }
}

class _DailyRow extends StatelessWidget {
  const _DailyRow({required this.day, required this.temperatureUnit, required this.isToday});

  final DailyWeather day;
  final TemperatureUnit temperatureUnit;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              isToday ? 'Today' : DateFormatter.shortWeekday(day.date),
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          WeatherIcon(code: day.weatherCode, size: 24),
          const Spacer(),
          if (day.precipitationProbabilityMax > 0) ...[
            Icon(Icons.water_drop_outlined, size: 14, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              '${day.precipitationProbabilityMax}%',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            '${day.temperatureMin.round()}° / ${day.temperatureMax.round()}°',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
