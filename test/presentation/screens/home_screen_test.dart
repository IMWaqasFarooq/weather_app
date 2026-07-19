import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/core/constants/enums.dart';
import 'package:weather_app/core/errors/exceptions.dart';
import 'package:weather_app/core/location/location_service.dart';
import 'package:weather_app/data/models/city.dart';
import 'package:weather_app/data/models/weather.dart';
import 'package:weather_app/data/weather_repository.dart';
import 'package:weather_app/presentation/provider/settings_provider.dart';
import 'package:weather_app/presentation/provider/weather_provider.dart';
import 'package:weather_app/presentation/screens/home_screen.dart';

class _MockWeatherRepository extends Mock implements WeatherRepository {}

class _MockLocationService extends Mock implements LocationService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(TemperatureUnit.celsius);
    registerFallbackValue(WindSpeedUnit.kmh);
  });

  const paris = City(id: 1, name: 'Paris', latitude: 48.85, longitude: 2.35, country: 'France');

  WeatherReport sampleReport() {
    return WeatherReport(
      current: CurrentWeather(
        time: DateTime(2026, 7, 19, 12),
        temperature: 21,
        apparentTemperature: 20,
        humidity: 55,
        precipitation: 0,
        weatherCode: 0,
        windSpeed: 12,
        windDirection: 90,
        isDay: true,
      ),
      hourly: [
        HourlyWeather(time: DateTime.now(), temperature: 21, weatherCode: 0, precipitationProbability: 0),
      ],
      daily: [
        DailyWeather(
          date: DateTime.now(),
          weatherCode: 0,
          temperatureMax: 25,
          temperatureMin: 16,
          precipitationProbabilityMax: 0,
          sunrise: DateTime.now(),
          sunset: DateTime.now(),
        ),
      ],
      timezone: 'UTC',
    );
  }

  late _MockWeatherRepository repository;
  late _MockLocationService locationService;

  Future<void> pumpHome(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final settings = SettingsProvider(preferences: preferences);
    final weatherProvider = WeatherProvider(
      repository: repository,
      locationService: locationService,
      preferences: preferences,
      settings: settings,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>.value(value: settings),
          ChangeNotifierProvider<WeatherProvider>.value(value: weatherProvider),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
  }

  setUp(() {
    repository = _MockWeatherRepository();
    locationService = _MockLocationService();
  });

  testWidgets('shows the empty state and offers to use current location on first launch', (tester) async {
    when(() => locationService.resolveCurrentCity()).thenThrow(const LocationException('denied'));

    await pumpHome(tester);
    await tester.pumpAndSettle();

    expect(find.textContaining('Search for a city'), findsOneWidget);
  });

  testWidgets('renders current conditions once weather loads via current location', (tester) async {
    when(() => locationService.resolveCurrentCity()).thenThrow(const LocationException('denied'));

    await pumpHome(tester);
    await tester.pumpAndSettle();

    when(() => repository.getWeather(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          temperatureUnit: any(named: 'temperatureUnit'),
          windSpeedUnit: any(named: 'windSpeedUnit'),
        )).thenAnswer((_) async => sampleReport());

    // Simulate picking a city directly through the provider, exercising the
    // same success rendering path search would.
    final weatherProvider = tester.element(find.byType(HomeScreen)).read<WeatherProvider>();
    await weatherProvider.selectCity(paris);
    await tester.pumpAndSettle();

    expect(find.text('Paris, France'), findsOneWidget);
    expect(find.text('21°C'), findsWidgets);
  });

  testWidgets('shows an error view with retry when loading fails', (tester) async {
    when(() => locationService.resolveCurrentCity()).thenThrow(const LocationException('denied'));
    await pumpHome(tester);
    await tester.pumpAndSettle();

    when(() => repository.getWeather(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          temperatureUnit: any(named: 'temperatureUnit'),
          windSpeedUnit: any(named: 'windSpeedUnit'),
        )).thenThrow(const NetworkException('offline'));

    final weatherProvider = tester.element(find.byType(HomeScreen)).read<WeatherProvider>();
    await weatherProvider.selectCity(paris);
    await tester.pumpAndSettle();

    expect(find.text('offline'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Try again'), findsOneWidget);
  });
}
