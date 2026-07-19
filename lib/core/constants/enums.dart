enum TemperatureUnit {
  celsius,
  fahrenheit;

  String get label => this == TemperatureUnit.celsius ? '°C' : '°F';

  String get apiValue =>
      this == TemperatureUnit.celsius ? 'celsius' : 'fahrenheit';
}

enum WindSpeedUnit {
  kmh,
  mph;

  String get label => this == WindSpeedUnit.kmh ? 'km/h' : 'mph';

  String get apiValue => this == WindSpeedUnit.kmh ? 'kmh' : 'mph';
}

enum ViewStatus { initial, loading, refreshing, success, error }
