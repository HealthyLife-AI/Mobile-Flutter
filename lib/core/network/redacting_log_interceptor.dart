import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Request/response logger for debug builds only.
///
/// Attached by `createApiClient` only when `kDebugMode` is true, so release
/// builds carry no logging code path at all. Secrets are replaced with `***`
/// before printing: passwords, tokens and the FCM token never reach the log.
class RedactingLogInterceptor extends Interceptor {
  static const Set<String> _secretKeys = {
    'password',
    'current_password',
    'password_confirmation',
    'refresh_token',
    'access_token',
    'fcm_token',
    'authorization',
<<<<<<< HEAD
    // Health data the patient writes (quick requests, check-ins, sleep and
    // mood, food preferences, report titles): never in a log, debug or not.
    'note',
    'answers',
    'reason',
    'occasion_date',
    'sleep_hours',
    'sleep_quality',
    'stress',
    'mood',
    'likes',
    'dislikes',
    'title',
    'category',
    'report_date',
=======
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('→ ${options.method} ${options.uri} ${_redact(options.data)}');
    handler.next(options);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    debugPrint(
        '← ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
        '✖ ${err.response?.statusCode ?? err.type.name} ${err.requestOptions.method} ${err.requestOptions.uri.path}');
    handler.next(err);
  }

  static Object? _redact(Object? value) {
    if (value is Map) {
      return {
        for (final entry in value.entries)
          '${entry.key}': _secretKeys.contains('${entry.key}')
              ? '***'
              : _redact(entry.value),
      };
    }
    if (value is List) return value.map(_redact).toList();
    return value;
  }
}
