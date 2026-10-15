import 'package:dio/dio.dart';

import '../errors/app_exception.dart';
import 'api_client.dart';
import 'session_events.dart';
import 'token_refresh_coordinator.dart';
import 'token_store.dart';

/// Attaches the bearer token and recovers from expired access tokens.
///
/// * Adds `Authorization: Bearer <access>` to every request except those marked
///   `auth: false` (login, refresh, logout).
/// * On a 401, asks the [TokenRefreshCoordinator] for a fresh token (one
///   refresh shared by all concurrent callers) and replays the request once.
/// * On `403 follow_up_ended`, clears the session and raises an event. Every
///   route can return this, including `/auth/me`.
/// * On `403 consent_required`, raises an event. The session is kept, so the
///   patient only has to accept the new policy.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.dio,
    required this.store,
    required this.coordinator,
    required this.events,
  });

  /// The client this interceptor belongs to. Used to replay requests.
  final Dio dio;
  final TokenStore store;
  final TokenRefreshCoordinator coordinator;
  final SessionEvents events;

  static bool _requiresAuth(RequestOptions options) =>
      options.extra[kAuthRequiredKey] != false;

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (_requiresAuth(options)) {
      final tokens = await store.readTokens();
      if (tokens != null) {
        options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final status = err.response?.statusCode;

    // Login, refresh and logout report their own errors to the caller.
    if (!_requiresAuth(options)) return handler.next(err);

    final body = _bodyOf(err);
    final code = body['code'];

    if (status == 403 && code == 'follow_up_ended') {
      await store.clear();
      events.emit(SessionEvent(SessionEventType.followUpEnded, body: body));
      return handler.next(err);
    }
    if (status == 403 && code == 'consent_required') {
      events.emit(SessionEvent(SessionEventType.consentRequired, body: body));
      return handler.next(err);
    }
    if (status != 401 || options.extra[kAuthRetriedKey] == true) {
      return handler.next(err);
    }

    try {
      final sent = options.headers['Authorization'];
      final rejected = sent is String ? sent.replaceFirst('Bearer ', '') : null;
      final fresh = await coordinator.recover(rejectedAccessToken: rejected);
      options.headers['Authorization'] = 'Bearer $fresh';
      options.extra[kAuthRetriedKey] = true;
      handler.resolve(await dio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    } on AppException catch (refreshError) {
      // Refresh failed: a network error keeps the session, a 401 has already
      // cleared it. Either way the caller gets the real reason.
      handler.reject(DioException(
        requestOptions: options,
        error: refreshError,
        type: DioExceptionType.unknown,
      ));
    }
  }

  static Map<String, dynamic> _bodyOf(DioException err) {
    final data = err.response?.data;
    return data is Map ? Map<String, dynamic>.from(data) : const {};
  }
}
