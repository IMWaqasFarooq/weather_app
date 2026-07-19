import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/enums.dart';

// Persists theme mode and temperature unit preferences.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider({required SharedPreferences preferences})
      : _preferences = preferences {
    _load();
  }

  static const _themeModeKey = 'settings.theme_mode';
  static const _temperatureUnitKey = 'settings.temperature_unit';

  final SharedPreferences _preferences;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  TemperatureUnit _temperatureUnit = TemperatureUnit.celsius;
  TemperatureUnit get temperatureUnit => _temperatureUnit;

  WindSpeedUnit get windSpeedUnit => _temperatureUnit == TemperatureUnit.celsius
      ? WindSpeedUnit.kmh
      : WindSpeedUnit.mph;

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
