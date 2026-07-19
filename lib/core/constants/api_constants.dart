// Open-Meteo API endpoints and query field lists.
class ApiConstants {
  const ApiConstants._();

  static const String forecastBaseUrl =
      'https://api.open-meteo.com/v1/forecast';
  static const String geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';

  static const Duration requestTimeout = Duration(seconds: 12);

  static const List<String> currentWeatherFields = [
    'temperature_2m',
    'relative_humidity_2m',
    'apparent_temperature',
    'is_day',
    'precipitation',
    'weather_code',
    'wind_speed_10m',
    'wind_direction_10m',
  ];

  static const List<String> hourlyWeatherFields = [
    'temperature_2m',
    'weather_code',
    'precipitation_probability',
  ];

  static const List<String> dailyWeatherFields = [
    'weather_code',
    'temperature_2m_max',
    'temperature_2m_min',
    'precipitation_probability_max',
    'sunrise',
    'sunset',
  ];

  static const int forecastDays = 7;
}
