import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/enums.dart';

/// Persists and exposes user preferences: theme mode and temperature unit.
///
/// Kept separate from [WeatherProvider] so unit/theme concerns don't bloat
/// the weather-fetching state machine, and so widgets that only care about
/// display preferences (e.g. a settings toggle) don't rebuild on every
/// weather refresh.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider({required SharedPreferences preferences}) : _preferences = preferences {
    _load();
  }

  static const _themeModeKey = 'settings.theme_mode';
  static const _temperatureUnitKey = 'settings.temperature_unit';

  final SharedPreferences _preferences;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  TemperatureUnit _temperatureUnit = TemperatureUnit.celsius;
  TemperatureUnit get temperatureUnit => _temperatureUnit;

  WindSpeedUnit get windSpeedUnit =>
      _temperatureUnit == TemperatureUnit.celsius ? WindSpeedUnit.kmh : WindSpeedUnit.mph;

  void _load() {
    final storedTheme = _preferences.getString(_themeModeKey);
    if (storedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == storedTheme,
        orElse: () => ThemeMode.system,
      );
    }

    final storedUnit = _preferences.getString(_temperatureUnitKey);
    if (storedUnit != null) {
      _temperatureUnit = TemperatureUnit.values.firstWhere(
        (unit) => unit.name == storedUnit,
        orElse: () => TemperatureUnit.celsius,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _preferences.setString(_themeModeKey, mode.name);
  }

  Future<void> toggleTemperatureUnit() async {
    _temperatureUnit = _temperatureUnit == TemperatureUnit.celsius
        ? TemperatureUnit.fahrenheit
        : TemperatureUnit.celsius;
    notifyListeners();
    await _preferences.setString(_temperatureUnitKey, _temperatureUnit.name);
  }
}
