import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/core/constants/enums.dart';
import 'package:weather_app/presentation/provider/settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsProvider', () {
    test('defaults to system theme and celsius when nothing is stored',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final settings = SettingsProvider(preferences: prefs);

      expect(settings.themeMode, ThemeMode.system);
      expect(settings.temperatureUnit, TemperatureUnit.celsius);
      expect(settings.windSpeedUnit, WindSpeedUnit.kmh);
    });

    test('restores previously persisted preferences', () async {
      SharedPreferences.setMockInitialValues({
        'settings.theme_mode': 'dark',
        'settings.temperature_unit': 'fahrenheit',
      });
      final prefs = await SharedPreferences.getInstance();
      final settings = SettingsProvider(preferences: prefs);

      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.temperatureUnit, TemperatureUnit.fahrenheit);
      expect(settings.windSpeedUnit, WindSpeedUnit.mph);
    });

    test('toggleTemperatureUnit flips the unit, notifies and persists',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final settings = SettingsProvider(preferences: prefs);

      var notified = 0;
      settings.addListener(() => notified++);

      await settings.toggleTemperatureUnit();

      expect(settings.temperatureUnit, TemperatureUnit.fahrenheit);
      expect(notified, 1);
      expect(prefs.getString('settings.temperature_unit'), 'fahrenheit');

      await settings.toggleTemperatureUnit();
      expect(settings.temperatureUnit, TemperatureUnit.celsius);
    });

    test('setThemeMode updates and persists, but is a no-op for the same mode',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final settings = SettingsProvider(preferences: prefs);

      var notified = 0;
      settings.addListener(() => notified++);

      await settings.setThemeMode(ThemeMode.dark);
      expect(settings.themeMode, ThemeMode.dark);
      expect(notified, 1);
      expect(prefs.getString('settings.theme_mode'), 'dark');

      await settings.setThemeMode(ThemeMode.dark);
      expect(notified, 1,
          reason: 'setting the same mode again should not notify');
    });
  });
}
