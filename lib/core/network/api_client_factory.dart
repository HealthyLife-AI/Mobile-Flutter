import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import 'api_client.dart';
import 'auth_interceptor.dart';
import 'redacting_log_interceptor.dart';
import 'retry_interceptor.dart';
import 'session_events.dart';
import 'token_refresh_coordinator.dart';
import 'token_store.dart';

/// Builds the one [ApiClient] the app uses.
///
/// Interceptor order matters:
/// 1. logging (debug only): sees each request before auth adds its header,
///    so the header itself is never logged;
/// 2. auth: adds the bearer token and recovers from 401/403 events;
/// 3. retry: retries idempotent GETs after the auth layer has had its turn.
ApiClient createApiClient({
  required TokenStore store,
  required TokenRefreshCoordinator coordinator,
  required SessionEvents events,
  String? baseUrl,
}) {
  final dio = Dio(BaseOptions(
    baseUrl: _withTrailingSlash(baseUrl ?? AppConfig.apiBaseUrl),
    connectTimeout: AppConfig.connectTimeout,
    sendTimeout: AppConfig.sendTimeout,
    receiveTimeout: AppConfig.receiveTimeout,
    headers: const {'Accept': 'application/json'},
    contentType: Headers.jsonContentType,
  ));

  if (kDebugMode) dio.interceptors.add(RedactingLogInterceptor());
  dio.interceptors.add(AuthInterceptor(
    dio: dio,
    store: store,
    coordinator: coordinator,
    events: events,
  ));
  dio.interceptors.add(RetryInterceptor(dio: dio));

  return DioApiClient(dio);
}

/// Dio joins relative paths onto the base URL only when it ends with `/`.
/// Without it, `api/v1` plus `auth/login` would drop the `v1` segment.
String _withTrailingSlash(String url) => url.endsWith('/') ? url : '$url/';
