import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/models/city.dart';
import '../errors/exceptions.dart';

// Wraps Geolocator and the device's native geocoder for location lookups.
class LocationService {
  LocationService({Geocoding? geocoding})
      : _geocoding = geocoding ?? Geocoding();

  final Geocoding _geocoding;

  Future<Position> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const LocationException(
          'Location services are disabled. Enable them in your device settings.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw const LocationException('Location permission was denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw const LocationException(
          'Location permission is permanently denied. Enable it from app settings.',
        );
      }

      return await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.medium),
      );
    } on LocationException {
      rethrow;
    } catch (e) {
      // Normalize platform-specific exceptions to our own type.
      throw LocationException('Could not determine your location: $e');
    }
  }

  // Reverse-geocodes the current position into a City, falling back to a
  // generic label if the geocoder is unavailable or returns nothing.
  Future<City> resolveCurrentCity() async {
    final position = await getCurrentPosition();

    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final name = _firstNonEmpty([
              placemark.locality,
              placemark.subAdministrativeArea,
              placemark.administrativeArea,
            ]) ??
            'My Location';
        return City.currentLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          name: name,
          country: placemark.country ?? '',
        );
      }
    } catch (_) {
      // Fall back to generic label below.
    }

    return City.currentLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      name: 'My Location',
    );
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }
}
