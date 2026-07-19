/// Temperature unit used for both the API request and display formatting.
enum TemperatureUnit {
  celsius,
  fahrenheit;

  String get label => this == TemperatureUnit.celsius ? '°C' : '°F';

  /// Value expected by Open-Meteo's `temperature_unit` query parameter.
  String get apiValue => this == TemperatureUnit.celsius ? 'celsius' : 'fahrenheit';
}

/// Wind speed unit, kept in lockstep with [TemperatureUnit] so metric always
/// pairs km/h with Celsius and imperial pairs mph with Fahrenheit.
enum WindSpeedUnit {
  kmh,
  mph;

  String get label => this == WindSpeedUnit.kmh ? 'km/h' : 'mph';

  String get apiValue => this == WindSpeedUnit.kmh ? 'kmh' : 'mph';
}

/// High-level state of an async load, used by providers to drive UI.
enum ViewStatus { initial, loading, refreshing, success, error }
