// Base type for errors thrown by the data layer.
abstract class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection.']);
}

class ServerException extends AppException {
  const ServerException(
      [super.message = 'Server returned an unexpected response.']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'No matching city was found.']);
}

class LocationException extends AppException {
  const LocationException(super.message);
}
