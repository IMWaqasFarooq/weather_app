import 'package:flutter/material.dart';

/// Maps Open-Meteo's WMO weather codes to a human-readable description and
/// a Material icon, since the API only returns a numeric code.
///
/// Reference: https://open-meteo.com/en/docs#weathervariables (WMO code table)
class WeatherCodeMapper {
  const WeatherCodeMapper._();

  static String description(int code) {
    switch (code) {
      case 0:
        return 'Clear sky';
      case 1:
        return 'Mainly clear';
      case 2:
        return 'Partly cloudy';
      case 3:
        return 'Overcast';
      case 45:
        return 'Fog';
      case 48:
        return 'Depositing rime fog';
      case 51:
        return 'Light drizzle';
      case 53:
        return 'Moderate drizzle';
      case 55:
        return 'Dense drizzle';
      case 56:
        return 'Light freezing drizzle';
      case 57:
        return 'Dense freezing drizzle';
      case 61:
        return 'Slight rain';
      case 63:
        return 'Moderate rain';
      case 65:
        return 'Heavy rain';
      case 66:
        return 'Light freezing rain';
      case 67:
        return 'Heavy freezing rain';
      case 71:
        return 'Slight snow fall';
      case 73:
        return 'Moderate snow fall';
      case 75:
        return 'Heavy snow fall';
      case 77:
        return 'Snow grains';
      case 80:
        return 'Slight rain showers';
      case 81:
        return 'Moderate rain showers';
      case 82:
        return 'Violent rain showers';
      case 85:
        return 'Slight snow showers';
      case 86:
        return 'Heavy snow showers';
      case 95:
        return 'Thunderstorm';
      case 96:
        return 'Thunderstorm with slight hail';
      case 99:
        return 'Thunderstorm with heavy hail';
      default:
        return 'Unknown';
    }
  }

  static IconData icon(int code, {bool isDay = true}) {
    if (code == 0) {
      return isDay ? Icons.wb_sunny : Icons.nightlight_round;
    }
    if (code == 1 || code == 2) {
      return isDay ? Icons.wb_cloudy_outlined : Icons.nights_stay_outlined;
    }
    if (code == 3) {
      return Icons.cloud;
    }
    if (code == 45 || code == 48) {
      return Icons.foggy;
    }
    if ((code >= 51 && code <= 57) || (code >= 80 && code <= 82)) {
      return Icons.grain;
    }
    if (code >= 61 && code <= 67) {
      return Icons.water_drop;
    }
    if ((code >= 71 && code <= 77) || code == 85 || code == 86) {
      return Icons.ac_unit;
    }
    if (code >= 95) {
      return Icons.thunderstorm;
    }
    return Icons.help_outline;
  }
}
