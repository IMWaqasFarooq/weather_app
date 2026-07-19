import 'package:equatable/equatable.dart';

/// A searchable location, sourced from Open-Meteo's geocoding API.
class City extends Equatable {
  const City({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    this.admin1,
    this.countryCode,
  });

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String country;

  /// First-level administrative region (state/province), when available.
  final String? admin1;
  final String? countryCode;

  /// A synthetic city used for "current location" results, where we only
  /// have coordinates and a resolved label, not a geocoding database id.
  factory City.currentLocation({
    required double latitude,
    required double longitude,
    required String name,
    String country = '',
  }) {
    return City(
      id: -1,
      name: name,
      latitude: latitude,
      longitude: longitude,
      country: country,
    );
  }

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String? ?? '',
      admin1: json['admin1'] as String?,
      countryCode: json['country_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'admin1': admin1,
      'country_code': countryCode,
    };
  }

  /// A short, display-friendly label, e.g. "Paris, Île-de-France, France".
  String get displayName {
    final parts = [name, if (admin1 != null && admin1 != name) admin1, country]
        .where((part) => part != null && part.isNotEmpty);
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [id, name, latitude, longitude, country, admin1, countryCode];
}
