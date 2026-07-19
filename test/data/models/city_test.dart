import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/data/models/city.dart';

void main() {
  group('City', () {
    test('fromJson parses a full geocoding result', () {
      final json = {
        'id': 2988507,
        'name': 'Paris',
        'latitude': 48.85341,
        'longitude': 2.3488,
        'country': 'France',
        'admin1': 'Île-de-France',
        'country_code': 'FR',
      };

      final city = City.fromJson(json);

      expect(city.id, 2988507);
      expect(city.name, 'Paris');
      expect(city.latitude, 48.85341);
      expect(city.longitude, 2.3488);
      expect(city.country, 'France');
      expect(city.admin1, 'Île-de-France');
      expect(city.countryCode, 'FR');
    });

    test('fromJson tolerates missing optional fields', () {
      final json = {
        'id': 1,
        'name': 'Nowhere',
        'latitude': 0.0,
        'longitude': 0.0,
      };

      final city = City.fromJson(json);

      expect(city.country, '');
      expect(city.admin1, isNull);
      expect(city.countryCode, isNull);
    });

    test('toJson/fromJson round-trips', () {
      const city = City(
        id: 5,
        name: 'London',
        latitude: 51.51,
        longitude: -0.12,
        country: 'United Kingdom',
        admin1: 'England',
        countryCode: 'GB',
      );

      final roundTripped = City.fromJson(city.toJson());

      expect(roundTripped, city);
    });

    test('displayName joins name, admin1 and country, skipping blanks/duplicates', () {
      const withRegion = City(
        id: 1,
        name: 'Paris',
        latitude: 0,
        longitude: 0,
        country: 'France',
        admin1: 'Île-de-France',
      );
      expect(withRegion.displayName, 'Paris, Île-de-France, France');

      const withoutRegion = City(
        id: 2,
        name: 'Singapore',
        latitude: 0,
        longitude: 0,
        country: 'Singapore',
      );
      expect(withoutRegion.displayName, 'Singapore, Singapore');

      const sameAsCity = City(
        id: 3,
        name: 'Monaco',
        latitude: 0,
        longitude: 0,
        country: 'Monaco',
        admin1: 'Monaco',
      );
      expect(sameAsCity.displayName, 'Monaco, Monaco');
    });

    test('two cities with the same fields are equal', () {
      const a = City(id: 1, name: 'A', latitude: 1, longitude: 1, country: 'X');
      const b = City(id: 1, name: 'A', latitude: 1, longitude: 1, country: 'X');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('City.currentLocation builds a synthetic entry with id -1', () {
      final city = City.currentLocation(latitude: 10, longitude: 20, name: 'My Location');
      expect(city.id, -1);
      expect(city.name, 'My Location');
      expect(city.latitude, 10);
      expect(city.longitude, 20);
    });
  });
}
