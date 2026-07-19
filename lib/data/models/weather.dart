import 'package:equatable/equatable.dart';

// Current conditions at the moment the report was fetched.
class CurrentWeather extends Equatable {
  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    required this.windDirection,
    required this.isDay,
  });

  final DateTime time;
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;
  final int windDirection;
  final bool isDay;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      time: DateTime.parse(json['time'] as String),
      temperature: (json['temperature_2m'] as num).toDouble(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      humidity: (json['relative_humidity_2m'] as num).round(),
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0,
      weatherCode: (json['weather_code'] as num).toInt(),
      windSpeed: (json['wind_speed_10m'] as num).toDouble(),
      windDirection: (json['wind_direction_10m'] as num?)?.toInt() ?? 0,
      isDay: (json['is_day'] as num) == 1,
    );
  }

  @override
  List<Object?> get props => [
        time,
        temperature,
        apparentTemperature,
        humidity,
        precipitation,
        weatherCode,
        windSpeed,
        windDirection,
        isDay,
      ];
}

// One hour of forecast data.
class HourlyWeather extends Equatable {
  const HourlyWeather({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
  });

  final DateTime time;
  final double temperature;
  final int weatherCode;
  final int precipitationProbability;

  @override
  List<Object?> get props =>
      [time, temperature, weatherCode, precipitationProbability];
}

// One day of forecast data.
class DailyWeather extends Equatable {
  const DailyWeather({
    required this.date,
    required this.weatherCode,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.precipitationProbabilityMax,
    required this.sunrise,
    required this.sunset,
  });

  final DateTime date;
  final int weatherCode;
  final double temperatureMax;
  final double temperatureMin;
  final int precipitationProbabilityMax;
  final DateTime sunrise;
  final DateTime sunset;

  @override
  List<Object?> get props => [
        date,
        weatherCode,
        temperatureMax,
        temperatureMin,
        precipitationProbabilityMax,
        sunrise,
        sunset,
      ];
}

// Full weather report: current conditions plus hourly and daily forecasts.
class WeatherReport extends Equatable {
  const WeatherReport({
    required this.current,
    required this.hourly,
    required this.daily,
    required this.timezone,
  });

  final CurrentWeather current;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;
  final String timezone;

  factory WeatherReport.fromJson(Map<String, dynamic> json) {
    final hourlyJson = json['hourly'] as Map<String, dynamic>;
    final hourlyTimes = hourlyJson['time'] as List<dynamic>;
    final hourlyTemps = hourlyJson['temperature_2m'] as List<dynamic>;
    final hourlyCodes = hourlyJson['weather_code'] as List<dynamic>;
    final hourlyPrecip =
        hourlyJson['precipitation_probability'] as List<dynamic>;

    final hourly = <HourlyWeather>[
      for (var i = 0; i < hourlyTimes.length; i++)
        HourlyWeather(
          time: DateTime.parse(hourlyTimes[i] as String),
          temperature: (hourlyTemps[i] as num).toDouble(),
          weatherCode: (hourlyCodes[i] as num).toInt(),
          precipitationProbability: (hourlyPrecip[i] as num?)?.toInt() ?? 0,
        ),
    ];

    final dailyJson = json['daily'] as Map<String, dynamic>;
    final dailyDates = dailyJson['time'] as List<dynamic>;
    final dailyCodes = dailyJson['weather_code'] as List<dynamic>;
    final dailyMax = dailyJson['temperature_2m_max'] as List<dynamic>;
    final dailyMin = dailyJson['temperature_2m_min'] as List<dynamic>;
    final dailyPrecip =
        dailyJson['precipitation_probability_max'] as List<dynamic>;
    final dailySunrise = dailyJson['sunrise'] as List<dynamic>;
    final dailySunset = dailyJson['sunset'] as List<dynamic>;

    final daily = <DailyWeather>[
      for (var i = 0; i < dailyDates.length; i++)
        DailyWeather(
          date: DateTime.parse(dailyDates[i] as String),
          weatherCode: (dailyCodes[i] as num).toInt(),
          temperatureMax: (dailyMax[i] as num).toDouble(),
          temperatureMin: (dailyMin[i] as num).toDouble(),
          precipitationProbabilityMax: (dailyPrecip[i] as num?)?.toInt() ?? 0,
          sunrise: DateTime.parse(dailySunrise[i] as String),
          sunset: DateTime.parse(dailySunset[i] as String),
        ),
    ];

    return WeatherReport(
      current: CurrentWeather.fromJson(json['current'] as Map<String, dynamic>),
      hourly: hourly,
      daily: daily,
      timezone: json['timezone'] as String? ?? 'UTC',
    );
  }

  @override
  List<Object?> get props => [current, hourly, daily, timezone];
}
