import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/core/constants/enums.dart';
import 'package:weather_app/core/errors/exceptions.dart';
import 'package:weather_app/core/errors/failures.dart';
import 'package:weather_app/core/location/location_service.dart';
import 'package:weather_app/data/models/city.dart';
import 'package:weather_app/data/models/weather.dart';
import 'package:weather_app/data/weather_repository.dart';
import 'package:weather_app/presentation/provider/settings_provider.dart';
import 'package:weather_app/presentation/provider/weather_provider.dart';

class _MockWeatherRepository extends Mock implements WeatherRepository {}

class _MockLocationService extends Mock implements LocationService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(TemperatureUnit.celsius);
    registerFallbackValue(WindSpeedUnit.kmh);
  });

  const paris = City(
      id: 1,
      name: 'Paris',
      latitude: 48.85,
      longitude: 2.35,
      country: 'France');
  const london = City(
      id: 2, name: 'London', latitude: 51.51, longitude: -0.12, country: 'UK');

  WeatherReport sampleReport({double temperature = 20}) {
    return WeatherReport(
      current: CurrentWeather(
        time: DateTime(2026, 7, 19, 12),
        temperature: temperature,
        apparentTemperature: temperature - 1,
        humidity: 50,
        precipitation: 0,
        weatherCode: 0,
        windSpeed: 5,
        windDirection: 180,
        isDay: true,
      ),
      hourly: const [],
      daily: const [],
      timezone: 'UTC',
    );
  }

  late _MockWeatherRepository repository;
  late _MockLocationService locationService;
  late SharedPreferences preferences;
  late SettingsProvider settings;
  late WeatherProvider provider;

  setUp(() async {
    repository = _MockWeatherRepository();
    locationService = _MockLocationService();
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    settings = SettingsProvider(preferences: preferences);
    provider = WeatherProvider(
      repository: repository,
      locationService: locationService,
      preferences: preferences,
      settings: settings,
    );
  });

  void stubWeather(City city, WeatherReport report) {
    when(() => repository.getWeather(
          latitude: city.latitude,
          longitude: city.longitude,
          temperatureUnit: TemperatureUnit.celsius,
          windSpeedUnit: WindSpeedUnit.kmh,
        )).thenAnswer((_) async => report);
  }

  group('selectCity', () {
    test('fetches weather and moves to success', () async {
      stubWeather(paris, sampleReport());

      await provider.selectCity(paris);

      expect(provider.status, ViewStatus.success);
      expect(provider.city, paris);
      expect(provider.report?.current.temperature, 20);
      expect(provider.failure, isNull);
    });

    test('adds the city to recents and persists it', () async {
      stubWeather(paris, sampleReport());

      await provider.selectCity(paris);

      expect(provider.recentCities, [paris]);
      expect(preferences.getStringList('weather.recent_cities'), isNotNull);
    });

    test('maps a NetworkException to NetworkFailure and sets error status',
        () async {
      when(() => repository.getWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            temperatureUnit: any(named: 'temperatureUnit'),
            windSpeedUnit: any(named: 'windSpeedUnit'),
          )).thenThrow(const NetworkException('offline'));

      await provider.selectCity(paris);

      expect(provider.status, ViewStatus.error);
      expect(provider.failure, isA<NetworkFailure>());
      expect(provider.failure?.message, 'offline');
    });

    test(
        'most recently selected city is moved to the front, without duplicates',
        () async {
      stubWeather(paris, sampleReport());
      stubWeather(london, sampleReport(temperature: 15));

      await provider.selectCity(paris);
      await provider.selectCity(london);
      await provider.selectCity(paris);

      expect(provider.recentCities, [paris, london]);
    });
  });

  group('useCurrentLocation', () {
    test(
        'resolves the current city via the location service and fetches weather',
        () async {
      when(() => locationService.resolveCurrentCity())
          .thenAnswer((_) async => paris);
      stubWeather(paris, sampleReport());

      await provider.useCurrentLocation();

      expect(provider.status, ViewStatus.success);
      expect(provider.isUsingCurrentLocation, isTrue);
      expect(provider.city, paris);
    });

    test('silent fallback swallows a location failure on first launch',
        () async {
      when(() => locationService.resolveCurrentCity())
          .thenThrow(const LocationException('denied'));

      await provider.useCurrentLocation(silentFallback: true);

      expect(provider.status, ViewStatus.initial);
      expect(provider.failure, isNull);
    });

    test('surfaces a LocationFailure when not silent', () async {
      when(() => locationService.resolveCurrentCity())
          .thenThrow(const LocationException('denied'));

      await provider.useCurrentLocation();

      expect(provider.status, ViewStatus.error);
      expect(provider.failure, isA<LocationFailure>());
      expect(provider.failure?.message, 'denied');
    });
  });

  group('refresh', () {
    test(
        're-fetches for the current city without adding a duplicate recent entry',
        () async {
      stubWeather(paris, sampleReport());
      await provider.selectCity(paris);

      stubWeather(paris, sampleReport(temperature: 30));
      await provider.refresh();

      expect(provider.report?.current.temperature, 30);
      expect(provider.recentCities, [paris]);
    });

    test('does nothing when no city has been selected yet', () async {
      await provider.refresh();
      expect(provider.status, ViewStatus.initial);
      verifyNever(() => repository.getWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            temperatureUnit: any(named: 'temperatureUnit'),
            windSpeedUnit: any(named: 'windSpeedUnit'),
          ));
    });
  });

  group('updateSettings', () {
    test('refetches with the new unit when the temperature unit changes',
        () async {
      stubWeather(paris, sampleReport());
      await provider.selectCity(paris);

      when(() => repository.getWeather(
            latitude: paris.latitude,
            longitude: paris.longitude,
            temperatureUnit: TemperatureUnit.fahrenheit,
            windSpeedUnit: WindSpeedUnit.mph,
          )).thenAnswer((_) async => sampleReport(temperature: 68));

      await settings.toggleTemperatureUnit();
      provider.updateSettings(settings);
      await Future<void>.delayed(Duration.zero);

      expect(provider.report?.current.temperature, 68);
    });
  });
}
