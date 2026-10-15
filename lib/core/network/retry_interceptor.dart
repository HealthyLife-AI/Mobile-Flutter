import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'api_client.dart';

/// Retries idempotent GET requests that failed for a transient reason:
/// connection problems, timeouts, 5xx, and 429 with a short `Retry-After`.
///
/// Writes (POST/PUT/PATCH/DELETE) are never retried here. Meal logs and
/// measurements are replayed by the offline queue with their idempotency keys
/// instead, so a retry can never create a duplicate.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = AppConfig.maxGetRetries,
    this.maxRetryAfter = AppConfig.maxAutoRetryAfter,
  });

  final Dio dio;
  final int maxRetries;

  /// A longer `Retry-After` is not waited for. The caller gets the failure
  /// and can show the countdown.
  final Duration maxRetryAfter;

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    if (options.method != 'GET' || !_isTransient(err)) {
      return handler.next(err);
    }

    final attempt = (options.extra[kRetryAttemptKey] as int?) ?? 0;
    if (attempt >= maxRetries) return handler.next(err);

    final delay = _delayFor(err, attempt);
    if (delay == null) return handler.next(err);

    await Future<void>.delayed(delay);
    options.extra[kRetryAttemptKey] = attempt + 1;
    try {
      handler.resolve(await dio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  static bool _isTransient(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError =>
        true,
      DioExceptionType.badResponse => () {
          final status = e.response?.statusCode ?? 0;
          return status == 429 || status >= 500;
        }(),
      _ => false,
    };
  }

  /// Backoff of 400 ms, then 800 ms, unless the server named a wait.
  Duration? _delayFor(DioException e, int attempt) {
    final retryAfter = retryAfterOf(e.response);
    if (retryAfter != null) {
      return retryAfter <= maxRetryAfter ? retryAfter : null;
    }
    return Duration(milliseconds: 400 * (1 << attempt));
  }
}
