import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/enums.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/location/location_service.dart';
import '../../data/models/city.dart';
import '../../data/models/weather.dart';
import '../../data/weather_repository.dart';
import 'settings_provider.dart';

/// Drives the weather screen: holds the selected city, the current
/// [WeatherReport], load status, and the recent-cities list.
///
/// Depends on [SettingsProvider] (via [updateSettings], wired through a
/// `ChangeNotifierProxyProvider`) purely to read the active temperature/wind
/// units when fetching — settings changes trigger an automatic refetch so
/// the displayed numbers always match the selected unit.
class WeatherProvider extends ChangeNotifier {
  WeatherProvider({
    required WeatherRepository repository,
    required LocationService locationService,
    required SharedPreferences preferences,
    required SettingsProvider settings,
  })  : _repository = repository,
        _locationService = locationService,
        _preferences = preferences,
        _settings = settings {
    _recentCities = _loadRecentCities();
  }

  static const _recentCitiesKey = 'weather.recent_cities';
  static const _maxRecentCities = 6;

  final WeatherRepository _repository;
  final LocationService _locationService;
  final SharedPreferences _preferences;
  SettingsProvider _settings;

  ViewStatus _status = ViewStatus.initial;
  ViewStatus get status => _status;

  City? _city;
  City? get city => _city;

  WeatherReport? _report;
  WeatherReport? get report => _report;

  Failure? _failure;
  Failure? get failure => _failure;

  bool _isUsingCurrentLocation = false;
  bool get isUsingCurrentLocation => _isUsingCurrentLocation;

  late List<City> _recentCities;
  List<City> get recentCities => List.unmodifiable(_recentCities);

  TemperatureUnit? _lastFetchedUnit;

  /// Called by a `ChangeNotifierProxyProvider` whenever [SettingsProvider]
  /// changes. Refetches automatically if the unit actually changed and a
  /// location is already loaded.
  void updateSettings(SettingsProvider settings) {
    _settings = settings;
    if (_city != null && _lastFetchedUnit != null && _lastFetchedUnit != settings.temperatureUnit) {
      _fetchWeather(_city!, preserveCity: true);
    }
  }

  /// Attempts to use the device's current location; falls back silently to
  /// the most recent city (or does nothing, leaving the empty state) if
  /// location isn't available. Intended for first launch.
  Future<void> loadInitialWeather() async {
    if (_recentCities.isNotEmpty) {
      await selectCity(_recentCities.first, addToRecents: false);
      return;
    }
    await useCurrentLocation(silentFallback: true);
  }

  Future<void> useCurrentLocation({bool silentFallback = false}) async {
    _status = ViewStatus.loading;
    _failure = null;
    notifyListeners();

    try {
      final city = await _locationService.resolveCurrentCity();
      _isUsingCurrentLocation = true;
      await _fetchWeather(city, addToRecents: false);
    } on LocationException catch (e) {
      if (silentFallback) {
        _status = ViewStatus.initial;
        notifyListeners();
      } else {
        _status = ViewStatus.error;
        _failure = LocationFailure(e.message);
        notifyListeners();
      }
    } on AppException catch (e) {
      if (silentFallback) {
        _status = ViewStatus.initial;
        notifyListeners();
      } else {
        _status = ViewStatus.error;
        _failure = _mapException(e);
        notifyListeners();
      }
    }
  }

  Future<void> selectCity(City city, {bool addToRecents = true}) async {
    _isUsingCurrentLocation = false;
    await _fetchWeather(city, addToRecents: addToRecents);
  }

  Future<void> refresh() async {
    if (_city == null) return;
    await _fetchWeather(_city!, addToRecents: false, isRefresh: true);
  }

  Future<void> _fetchWeather(
    City city, {
    bool addToRecents = true,
    bool isRefresh = false,
    bool preserveCity = false,
  }) async {
    _status = isRefresh ? ViewStatus.refreshing : ViewStatus.loading;
    _failure = null;
    if (!preserveCity) _city = city;
    notifyListeners();

    try {
      final unit = _settings.temperatureUnit;
      final report = await _repository.getWeather(
        latitude: city.latitude,
        longitude: city.longitude,
        temperatureUnit: unit,
        windSpeedUnit: _settings.windSpeedUnit,
      );
      _report = report;
      _city = city;
      _lastFetchedUnit = unit;
      _status = ViewStatus.success;
      if (addToRecents) _addToRecents(city);
      notifyListeners();
    } on AppException catch (e) {
      _status = ViewStatus.error;
      _failure = _mapException(e);
      notifyListeners();
    }
  }

  Failure _mapException(AppException e) {
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is NotFoundException) return NotFoundFailure(e.message);
    if (e is ServerException) return ServerFailure(e.message);
    return UnknownFailure(e.message);
  }

  List<City> _loadRecentCities() {
    final raw = _preferences.getStringList(_recentCitiesKey);
    if (raw == null) return [];
    return raw
        .map((entry) => City.fromJson(jsonDecode(entry) as Map<String, dynamic>))
        .toList();
  }

  void _addToRecents(City city) {
    _recentCities.removeWhere((c) => c.id == city.id && c.name == city.name);
    _recentCities.insert(0, city);
    if (_recentCities.length > _maxRecentCities) {
      _recentCities = _recentCities.sublist(0, _maxRecentCities);
    }
    unawaited(_persistRecentCities());
  }

  Future<void> _persistRecentCities() async {
    final encoded = _recentCities.map((c) => jsonEncode(c.toJson())).toList();
    await _preferences.setStringList(_recentCitiesKey, encoded);
  }

  Future<void> removeRecentCity(City city) async {
    _recentCities.removeWhere((c) => c.id == city.id && c.name == city.name);
    notifyListeners();
    await _persistRecentCities();
  }
}
