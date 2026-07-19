import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/data/models/weather.dart';

Map<String, dynamic> _sampleForecastJson() => {
      'timezone': 'Europe/Paris',
      'current': {
        'time': '2026-07-19T12:00',
        'temperature_2m': 25.3,
        'relative_humidity_2m': 40,
        'apparent_temperature': 24.7,
        'is_day': 1,
        'precipitation': 0.0,
        'weather_code': 1,
        'wind_speed_10m': 10.5,
        'wind_direction_10m': 220,
      },
      'hourly': {
        'time': ['2026-07-19T12:00', '2026-07-19T13:00'],
        'temperature_2m': [25.3, 26.1],
        'weather_code': [1, 2],
        'precipitation_probability': [0, 10],
      },
      'daily': {
        'time': ['2026-07-19', '2026-07-20'],
        'weather_code': [1, 61],
        'temperature_2m_max': [28.0, 24.5],
        'temperature_2m_min': [18.2, 17.0],
        'precipitation_probability_max': [5, 60],
        'sunrise': ['2026-07-19T06:02', '2026-07-20T06:03'],
        'sunset': ['2026-07-19T21:45', '2026-07-20T21:44'],
      },
    };

void main() {
  group('CurrentWeather', () {
    test('fromJson parses all fields', () {
      final current = CurrentWeather.fromJson(
          _sampleForecastJson()['current'] as Map<String, dynamic>);

      expect(current.temperature, 25.3);
      expect(current.apparentTemperature, 24.7);
      expect(current.humidity, 40);
      expect(current.precipitation, 0.0);
      expect(current.weatherCode, 1);
      expect(current.windSpeed, 10.5);
      expect(current.windDirection, 220);
      expect(current.isDay, isTrue);
    });

    test('is_day of 0 maps to false', () {
      final json = Map<String, dynamic>.from(
        _sampleForecastJson()['current'] as Map<String, dynamic>,
      )..['is_day'] = 0;

      expect(CurrentWeather.fromJson(json).isDay, isFalse);
    });
  });

  group('WeatherReport', () {
    test('fromJson parses current, hourly and daily arrays in lockstep', () {
      final report = WeatherReport.fromJson(_sampleForecastJson());

      expect(report.timezone, 'Europe/Paris');
      expect(report.current.temperature, 25.3);

      expect(report.hourly, hasLength(2));
      expect(report.hourly.first.temperature, 25.3);
      expect(report.hourly.last.temperature, 26.1);
      expect(report.hourly.last.weatherCode, 2);
      expect(report.hourly.last.precipitationProbability, 10);

      expect(report.daily, hasLength(2));
      expect(report.daily.first.temperatureMax, 28.0);
      expect(report.daily.first.temperatureMin, 18.2);
      expect(report.daily.last.weatherCode, 61);
      expect(report.daily.last.precipitationProbabilityMax, 60);
      expect(report.daily.first.sunrise, DateTime.parse('2026-07-19T06:02'));
      expect(report.daily.first.sunset, DateTime.parse('2026-07-19T21:45'));
    });

    test('defaults timezone to UTC when missing', () {
      final json = _sampleForecastJson()..remove('timezone');
      expect(WeatherReport.fromJson(json).timezone, 'UTC');
    });
  });
}
