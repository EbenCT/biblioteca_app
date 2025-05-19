// Base failure class
abstract class Failure {
  final String message;

  Failure(this.message);

  @override
  String toString() => message;
}

// Server failures
class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}

// Authentication failures
class AuthFailure extends Failure {
  AuthFailure(String message) : super(message);
}

// Network failures
class NetworkFailure extends Failure {
  NetworkFailure(String message) : super(message);
}

// Cache failures
class CacheFailure extends Failure {
  CacheFailure(String message) : super(message);
}

// Input validation failures
class ValidationFailure extends Failure {
  ValidationFailure(String message) : super(message);
}
