import 'package:flutter/foundation.dart';

/// Compile-time application configuration.
///
/// There is intentionally NO real backend wired yet: the project ships with
/// mock data sources (see `lib/data/`). [apiBaseUrl] is a placeholder that
/// must be replaced (e.g. via `--dart-define=API_BASE_URL=...`) when the
/// backend exists. Never hardcode secrets here — anything public (URLs,
/// feature flags) belongs here; anything secret must come from
/// `--dart-define` or a backend-provided session, never from source.
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.healthylife.invalid',
  );

  static const Duration connectTimeout = Duration(seconds: 12);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Simulated network latency for mock data sources so loading states are
  /// observable in the UI.
  static const Duration mockLatency = Duration(milliseconds: 650);

  @visibleForTesting
  static const bool useMockData = bool.fromEnvironment('USE_MOCK_DATA', defaultValue: true);
}
