// Base type for errors surfaced to the UI.
abstract class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure(
      [super.message =
          'No internet connection. Check your network and try again.']);
}

class ServerFailure extends Failure {
  const ServerFailure(
      [super.message =
          'Something went wrong on the weather server. Please try again.']);
}

class LocationFailure extends Failure {
  const LocationFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'No matching city was found.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
