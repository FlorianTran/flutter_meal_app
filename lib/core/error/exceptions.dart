/// Base class for all exceptions in the application
abstract class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

/// Server exception (network, API errors)
class ServerException extends AppException {
  const ServerException(super.message);
}

/// Cache exception (local storage errors)
class CacheException extends AppException {
  const CacheException(super.message);
}

/// General exception
class GeneralException extends AppException {
  const GeneralException(super.message);
}
