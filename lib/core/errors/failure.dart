import 'app_exception.dart' show NetworkFailureKind;

/// User-facing failure model for the domain layer.
///
/// Repositories return `Result<T>` carrying a [Failure] instead of throwing.
/// Presentation maps [Failure] to localized strings — never show
/// [debugMessage] to users.
sealed class Failure {
  const Failure({this.debugMessage});

  /// Developer-facing detail (logged, never rendered to users).
  final String? debugMessage;
}

class NetworkFailure extends Failure {
  const NetworkFailure({this.kind = NetworkFailureKind.unknown, super.debugMessage});

  final NetworkFailureKind kind;
}

class ServerFailure extends Failure {
  const ServerFailure({this.statusCode, super.debugMessage});

  final int? statusCode;
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.debugMessage});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.debugMessage});
}

class ValidationFailure extends Failure {
  const ValidationFailure({this.fieldErrors = const {}, super.debugMessage});

  final Map<String, String> fieldErrors;
}

class CacheFailure extends Failure {
  const CacheFailure({super.debugMessage});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.debugMessage, this.cause});

  final Object? cause;
}
