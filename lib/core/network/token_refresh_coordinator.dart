import '../errors/app_exception.dart';
import 'auth_tokens.dart';
import 'session_events.dart';
import 'token_store.dart';

/// Calls `POST /auth/refresh` with the given refresh token.
typedef RefreshCall = Future<AuthTokens> Function(String refreshToken);

/// Single-flight token refresh (API guide section 2.2–2.3).
///
/// * Many requests can fail with 401 at the same moment. The first one starts
///   the refresh; every other caller awaits that same future. The server only
///   ever receives one refresh per burst, which matters because a refresh token
///   is single use and re-using an old one ends every session of the patient.
/// * If another request already rotated the token while we were waiting, the
///   stored token is returned without a second refresh.
/// * 429 on refresh: wait `Retry-After` and retry with the **same** token. It
///   does not end the session.
/// * 401 on refresh: the session is over. Clear it and raise
///   [SessionEventType.expired].
/// * Network errors are rethrown and the session is kept, so the app can keep
///   working offline with the cached data.
class TokenRefreshCoordinator {
  TokenRefreshCoordinator({
    required TokenStore store,
    required SessionEvents events,
    required RefreshCall refresh,
    this.maxAttempts = 3,
  })  : _store = store,
        _events = events,
        _refresh = refresh;

  final TokenStore _store;
  final SessionEvents _events;
  final RefreshCall _refresh;
  final int maxAttempts;

  Future<String>? _inFlight;

  /// Returns a usable access token.
  ///
  /// Pass the access token that the server just rejected as
  /// [rejectedAccessToken]. Pass null to force a refresh (app start-up).
  Future<String> recover({String? rejectedAccessToken}) {
    final pending = _inFlight;
    if (pending != null) return pending;
    final next =
        _refreshOnce(rejectedAccessToken).whenComplete(() => _inFlight = null);
    _inFlight = next;
    return next;
  }

  Future<String> _refreshOnce(String? rejectedAccessToken) async {
    final current = await _store.readTokens();
    if (current == null) {
      throw const ApiException('Not signed in', statusCode: 401);
    }
    if (rejectedAccessToken != null &&
        current.accessToken != rejectedAccessToken) {
      // Another request already refreshed while this one was in flight.
      return current.accessToken;
    }

    var attempt = 0;
    while (true) {
      attempt++;
      try {
        final fresh = await _refresh(current.refreshToken);
        await _store.saveTokens(fresh);
        return fresh.accessToken;
      } on ApiException catch (e) {
        if (e.statusCode == 429 && attempt < maxAttempts) {
          await Future<void>.delayed(
              e.retryAfter ?? const Duration(seconds: 2));
          continue;
        }
        if (e.statusCode == 401) {
          await _store.clear();
          _events.emit(const SessionEvent(SessionEventType.expired));
        }
        rethrow;
      }
    }
  }
}
