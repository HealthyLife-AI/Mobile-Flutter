import 'package:flutter/foundation.dart';

/// Compile-time application configuration.
///
/// Public values only (URLs, timeouts, feature flags). Secrets must never be
/// written here: pass them with `--dart-define` or receive them from the
/// backend at sign-in.
///
/// Build examples:
///   flutter run --dart-define=API_BASE_URL=https://healthylife.apps.taqat.academy/api/v1
///   flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
class AppConfig {
  AppConfig._();

  /// Laravel API root (API guide section 1.1). Paths in the data sources are
  /// relative to this and must not start with `/`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://healthylife.apps.taqat.academy/api/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 12);
  static const Duration sendTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);

  /// Automatic retries for idempotent GET requests only (5xx, 429, network).
  /// Writes are never retried automatically; the offline queue owns them.
  static const int maxGetRetries = 2;

  /// A `Retry-After` longer than this is not waited for automatically; the
  /// screen shows the wait instead.
  static const Duration maxAutoRetryAfter = Duration(seconds: 10);

  /// Simulated network latency for the remaining mock data sources so loading
  /// states are observable in the UI.
  static const Duration mockLatency = Duration(milliseconds: 650);

  /// Only affects the mock repositories that are not wired to the API yet.
  /// Authentication always talks to the real API.
  @visibleForTesting
  static const bool useMockData =
      bool.fromEnvironment('USE_MOCK_DATA', defaultValue: true);
}
