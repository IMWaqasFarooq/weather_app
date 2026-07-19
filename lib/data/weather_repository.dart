import '../core/constants/api_constants.dart';
import '../core/constants/enums.dart';
import '../core/network/api_client.dart';
import 'models/city.dart';
import 'models/weather.dart';

/// Contract for fetching weather and location data, so the presentation
/// layer depends on this abstraction rather than a concrete HTTP client.
abstract class WeatherRepository {
  /// Looks up cities by name using Open-Meteo's geocoding search.
  Future<List<City>> searchCities(String query);

  /// Fetches current conditions plus hourly/daily forecasts for a location.
  Future<WeatherReport> getWeather({
    required double latitude,
    required double longitude,
    required TemperatureUnit temperatureUnit,
    required WindSpeedUnit windSpeedUnit,
  });
}

class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<City>> searchCities(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final json = await _apiClient.get(
      ApiConstants.geocodingBaseUrl,
      queryParameters: {
        'name': trimmed,
        'count': 10,
        'language': 'en',
        'format': 'json',
      },
    );

    final results = json['results'] as List<dynamic>?;
    if (results == null) return [];

    return results
        .map((result) => City.fromJson(result as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<WeatherReport> getWeather({
    required double latitude,
    required double longitude,
    required TemperatureUnit temperatureUnit,
    required WindSpeedUnit windSpeedUnit,
  }) async {
    final json = await _apiClient.get(
      ApiConstants.forecastBaseUrl,
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'current': ApiConstants.currentWeatherFields.join(','),
        'hourly': ApiConstants.hourlyWeatherFields.join(','),
        'daily': ApiConstants.dailyWeatherFields.join(','),
        'temperature_unit': temperatureUnit.apiValue,
        'wind_speed_unit': windSpeedUnit.apiValue,
        'timezone': 'auto',
        'forecast_days': ApiConstants.forecastDays,
      },
    );

    return WeatherReport.fromJson(json);
  }
}
