/// Base type for user-facing failures surfaced by providers.
///
/// The repository/network layer throws [AppException]s; the presentation
/// layer never deals with those directly. Instead providers catch them and
/// store a [Failure] in their state, so widgets only ever branch on this
/// small, UI-friendly set of cases.
abstract class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Check your network and try again.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on the weather server. Please try again.']);
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
