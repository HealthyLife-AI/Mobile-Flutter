/// Exception hierarchy thrown by the data layer.
///
/// These are technical exceptions: they may carry status codes, parse errors
/// and stack traces, and must NEVER be shown directly to end users. Convert
/// them to a [Failure] (see `failure.dart`) at the repository boundary, and
/// map failures to localized messages in presentation code.
sealed class AppException implements Exception {
  const AppException(this.message, {this.statusCode, this.cause});

  /// Developer-facing message. Never shown to users.
  final String message;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() => '$runtimeType($statusCode): $message';
}

/// Device is offline, DNS failed, connection refused, or the server was
/// unreachable for any transport-level reason.
class NetworkException extends AppException {
  const NetworkException(super.message, {this.kind = NetworkFailureKind.unknown, super.cause});

  final NetworkFailureKind kind;
}

enum NetworkFailureKind { offline, timeout, unknown }

/// Server answered with a 5xx (or an unparseable transport-level response
/// from a server that clearly received the request).
class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

/// Server answered 401/403 — session expired or insufficient permissions.
class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, {super.statusCode});
}

/// Server answered 404 — resource does not exist.
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.statusCode = 404});
}

/// Request was rejected as invalid (400/422) or failed local validation
/// before sending. [fieldErrors] maps field names → message keys/messages
/// coming from the server.
class ValidationException extends AppException {
  const ValidationException(super.message, {super.statusCode, this.fieldErrors = const {}});

  final Map<String, String> fieldErrors;
}

/// JSON/serialization failure while parsing a response or cached payload.
class ParseException extends AppException {
  const ParseException(super.message, {super.cause});
}

/// Local storage read/write failure.
class StorageException extends AppException {
  const StorageException(super.message, {super.cause});
}

/// Anything unexpected — bug, null violation, unhandled state.
class UnexpectedException extends AppException {
  const UnexpectedException(super.message, {super.cause});
}
