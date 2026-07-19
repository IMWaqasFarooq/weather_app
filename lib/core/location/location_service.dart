import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/models/city.dart';
import '../errors/exceptions.dart';

/// Wraps [Geolocator] (and the platform's native geocoder) so the rest of
/// the app depends on a small, mockable interface instead of two plugins.
///
/// Open-Meteo only offers forward geocoding (search by name), not reverse
/// geocoding, so resolving a display name for "current location" has to go
/// through the device's own geocoder instead.
class LocationService {
  LocationService({Geocoding? geocoding}) : _geocoding = geocoding ?? Geocoding();

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
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
    } on LocationException {
      rethrow;
    } catch (e) {
      // Geolocator's platform channels throw their own exception types (e.g.
      // for a misconfigured Info.plist/AndroidManifest) that aren't part of
      // our AppException hierarchy. Normalize everything here so callers
      // only ever have to handle LocationException.
      throw LocationException('Could not determine your location: $e');
    }
  }

  /// Resolves the device's current position into a displayable [City].
  ///
  /// Falls back to a generic "My Location" label if the native geocoder
  /// fails or returns nothing (e.g. it's unsupported on this platform, such
  /// as web) — that's a cosmetic gap, not a reason to fail the whole flow.
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
      // Fall through to the generic label below.
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
