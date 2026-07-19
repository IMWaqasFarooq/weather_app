import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:weather_app/core/constants/enums.dart';
import 'package:weather_app/core/errors/exceptions.dart';
import 'package:weather_app/core/network/api_client.dart';
import 'package:weather_app/data/weather_repository.dart';

class _MockHttpClient extends Mock implements http.Client {}

void main() {
  late _MockHttpClient httpClient;
  late WeatherRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  setUp(() {
    httpClient = _MockHttpClient();
    repository = WeatherRepositoryImpl(apiClient: ApiClient(client: httpClient));
  });

  http.Response jsonResponse(Map<String, dynamic> body, {int statusCode = 200}) {
    return http.Response(jsonEncode(body), statusCode);
  }

  group('searchCities', () {
    test('returns an empty list for a blank query without hitting the network', () async {
      final results = await repository.searchCities('   ');

      expect(results, isEmpty);
      verifyNever(() => httpClient.get(any()));
    });

    test('parses geocoding results into City models', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => jsonResponse({
          'results': [
            {
              'id': 2988507,
              'name': 'Paris',
              'latitude': 48.85,
              'longitude': 2.35,
              'country': 'France',
              'admin1': 'Île-de-France',
              'country_code': 'FR',
            },
          ],
        }),
      );

      final results = await repository.searchCities('Paris');

      expect(results, hasLength(1));
      expect(results.single.name, 'Paris');
      expect(results.single.country, 'France');
    });

    test('returns an empty list when the API has no matches', () async {
      when(() => httpClient.get(any())).thenAnswer((_) async => jsonResponse({'results': null}));

      final results = await repository.searchCities('Nowhereville');

      expect(results, isEmpty);
    });
  });

  group('getWeather', () {
    test('requests the configured units and parses the report', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => jsonResponse({
          'timezone': 'UTC',
          'current': {
            'time': '2026-07-19T12:00',
            'temperature_2m': 20.0,
            'relative_humidity_2m': 50,
            'apparent_temperature': 19.0,
            'is_day': 1,
            'precipitation': 0.0,
            'weather_code': 0,
            'wind_speed_10m': 5.0,
            'wind_direction_10m': 180,
          },
          'hourly': {
            'time': ['2026-07-19T12:00'],
            'temperature_2m': [20.0],
            'weather_code': [0],
            'precipitation_probability': [0],
          },
          'daily': {
            'time': ['2026-07-19'],
            'weather_code': [0],
            'temperature_2m_max': [22.0],
            'temperature_2m_min': [15.0],
            'precipitation_probability_max': [0],
            'sunrise': ['2026-07-19T06:00'],
            'sunset': ['2026-07-19T21:00'],
          },
        }),
      );

      final report = await repository.getWeather(
        latitude: 1,
        longitude: 2,
        temperatureUnit: TemperatureUnit.fahrenheit,
        windSpeedUnit: WindSpeedUnit.mph,
      );

      expect(report.current.temperature, 20.0);

      final capturedUri = verify(() => httpClient.get(captureAny())).captured.single as Uri;
      expect(capturedUri.queryParameters['temperature_unit'], 'fahrenheit');
      expect(capturedUri.queryParameters['wind_speed_unit'], 'mph');
      expect(capturedUri.queryParameters['latitude'], '1.0');
      expect(capturedUri.queryParameters['longitude'], '2.0');
    });

    test('throws NotFoundException on a 404 response', () async {
      when(() => httpClient.get(any())).thenAnswer((_) async => http.Response('not found', 404));

      expect(
        () => repository.getWeather(
          latitude: 1,
          longitude: 2,
          temperatureUnit: TemperatureUnit.celsius,
          windSpeedUnit: WindSpeedUnit.kmh,
        ),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('throws ServerException on a 500 response', () async {
      when(() => httpClient.get(any())).thenAnswer((_) async => http.Response('oops', 500));

      expect(
        () => repository.getWeather(
          latitude: 1,
          longitude: 2,
          temperatureUnit: TemperatureUnit.celsius,
          windSpeedUnit: WindSpeedUnit.kmh,
        ),
        throwsA(isA<ServerException>()),
      );
    });

    test('throws NetworkException when there is no connection', () async {
      when(() => httpClient.get(any())).thenThrow(const SocketException('no network'));

      expect(
        () => repository.getWeather(
          latitude: 1,
          longitude: 2,
          temperatureUnit: TemperatureUnit.celsius,
          windSpeedUnit: WindSpeedUnit.kmh,
        ),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
