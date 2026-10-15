/// Exception hierarchy thrown by the data layer.
///
/// These are technical exceptions: they may carry status codes, parse errors
/// and stack traces, and must NEVER be shown directly to end users. Convert
/// them to a [Failure] (see `failure.dart`) at the repository boundary, and
/// map failures to localized messages in presentation code.
///
/// NOTE: `sealed` restricts subclasses to this library, so every exception
/// type lives in this file. Add new ones here and extend `exception_mapper`.
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
  const NetworkException(super.message,
      {this.kind = NetworkFailureKind.unknown, super.cause});

  final NetworkFailureKind kind;
}

enum NetworkFailureKind { offline, timeout, unknown }

/// Server answered with a 5xx.
class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

/// Server answered 401/403 without a usable body. Prefer [ApiException],
/// which keeps the machine-readable `code` the API guide tells us to branch on.
class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, {super.statusCode});
}

/// Server answered 404 — resource does not exist, or is not this patient's.
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.statusCode = 404});
}

/// Request was rejected as invalid (400/422) or failed local validation
/// before sending. [fieldErrors] maps field names → message keys/messages
/// coming from the server.
class ValidationException extends AppException {
  const ValidationException(super.message,
      {super.statusCode, this.fieldErrors = const {}});

  final Map<String, String> fieldErrors;
}

/// A non-2xx answer (4xx) that carries the API's JSON body. Branch on [code]
/// (never on [message]); the API guide's section 15 lists every code.
///
/// Examples: 401 (no code), 403 `follow_up_ended` / `consent_required`,
/// 403 `log_locked`, 409 `consent_version_mismatch`, 423 (with `locked_until`
/// in [body]), 429 (with [retryAfter]).
class ApiException extends AppException {
  const ApiException(
    super.message, {
    super.statusCode,
    this.code,
    this.body = const {},
    this.retryAfter,
  });

  /// The API's `code` field, e.g. `follow_up_ended`. Null when absent.
  final String? code;

  /// Whole JSON body of the response (empty when it was not an object).
  final Map<String, dynamic> body;

  /// Parsed `Retry-After` header for 429 responses.
  final Duration? retryAfter;

  /// `errors` of a 422 response, one message per field.
  Map<String, String> get fieldErrors => fieldErrorsOf(body);
}

/// Flattens a Laravel-style `{"errors": {"field": ["message"]}}` body into a
/// map of field → first message. Returns an empty map when absent.
Map<String, String> fieldErrorsOf(Map<String, dynamic> body) {
  final errors = body['errors'];
  if (errors is! Map) return const {};
  return errors.map((key, value) => MapEntry(
        '$key',
        value is List && value.isNotEmpty ? '${value.first}' : '$value',
      ));
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
