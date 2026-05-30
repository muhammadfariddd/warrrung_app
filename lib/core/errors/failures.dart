/// Base class for all application failures.
class Failure implements Exception {
  final String message;
  final int? statusCode;

  Failure(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Failure representing server-side errors (e.g., PocketBase ClientException with HTTP status codes).
class ServerFailure extends Failure {
  ServerFailure(super.message, {super.statusCode});
}

/// Failure representing client-side connectivity or network issues.
class NetworkFailure extends Failure {
  NetworkFailure(super.message);
}
