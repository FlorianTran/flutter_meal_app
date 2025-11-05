/// Base class for all failures in the application
abstract class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;
}

/// Server failure (network, API errors)
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Cache failure (local storage errors)
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// General failure
class GeneralFailure extends Failure {
  const GeneralFailure(super.message);
}
