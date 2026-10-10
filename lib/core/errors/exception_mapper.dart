import '../../core/errors/failure.dart';
import '../../core/errors/result.dart';
import '../../core/errors/app_exception.dart';
import '../../core/logging/app_logger.dart';

/// Converts thrown [AppException]s (and unexpected errors) into [Failure]s
/// so repositories can return `Result` without leaking exceptions upward.
Failure failureFromException(Object error, [StackTrace? stack]) {
  if (error is AppException) {
    return switch (error) {
      NetworkException(:final kind) => NetworkFailure(kind: kind, debugMessage: error.message),
      ServerException(:final statusCode) => ServerFailure(statusCode: statusCode, debugMessage: error.message),
      UnauthorizedException() => UnauthorizedFailure(debugMessage: error.message),
      NotFoundException() => NotFoundFailure(debugMessage: error.message),
      ValidationException(:final fieldErrors) =>
        ValidationFailure(fieldErrors: fieldErrors, debugMessage: error.message),
      ParseException() => UnexpectedFailure(debugMessage: error.message, cause: error),
      StorageException() => CacheFailure(debugMessage: error.message),
      UnexpectedException(:final cause) => UnexpectedFailure(debugMessage: error.message, cause: cause),
    };
  }
  return UnexpectedFailure(debugMessage: '$error', cause: error);
}

/// Runs [body], catching every exception and returning a [Result].
/// Repositories should route all reads/writes through this.
Future<Result<T>> guard<T>(
  Future<T> Function() body, {
  AppLogger logger = const DefaultAppLogger(),
  String context = 'repository',
}) async {
  try {
    return Success(await body());
  } on AppException catch (e, st) {
    logger.warn('$context failed: $e', error: e);
    logger.debug('$context stack: $st');
    return Failed(failureFromException(e, st));
  } catch (e, st) {
    logger.error('$context unexpected error', error: e, stackTrace: st);
    return Failed(failureFromException(e, st));
  }
}
