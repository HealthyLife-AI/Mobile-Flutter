import 'package:flutter/foundation.dart';

/// Minimal application logger.
///
/// Never logs in release builds and never logs secrets — pass already-redacted
/// strings, or use [redact] for anything token/password-shaped.
abstract interface class AppLogger {
  void debug(String message);
  void info(String message);
  void warn(String message, {Object? error});
  void error(String message, {Object? error, StackTrace? stackTrace});
}

class DefaultAppLogger implements AppLogger {
  const DefaultAppLogger();

  bool get _enabled => kDebugMode;

  @override
  void debug(String message) {
    if (_enabled) debugPrint('[DEBUG] $message');
  }

  @override
  void info(String message) {
    if (_enabled) debugPrint('[INFO] $message');
  }

  @override
  void warn(String message, {Object? error}) {
    if (_enabled) {
      debugPrint('[WARN] $message${error == null ? '' : ' :: $error'}');
    }
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (_enabled) {
      debugPrint('[ERROR] $message${error == null ? '' : ' :: $error'}');
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
  }

  /// Replaces the tail of sensitive-looking values with `***` so accidental
  /// log payloads can't leak tokens, passwords or invite codes.
  static String redact(String value) {
    if (value.length <= 4) return '***';
    return '${value.substring(0, 2)}***${value.substring(value.length - 2)}';
  }
}

/// Logger that swallows everything — default in tests.
class SilentAppLogger implements AppLogger {
  const SilentAppLogger();

  @override
  void debug(String message) {}
  @override
  void info(String message) {}
  @override
  void warn(String message, {Object? error}) {}
  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}
}
