import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/network/auth_tokens.dart';
import 'package:healthylife_ai/core/network/session_events.dart';
import 'package:healthylife_ai/core/network/token_refresh_coordinator.dart';
import 'package:healthylife_ai/core/network/token_store.dart';

/// Follows the same contract as the real store: saving does nothing when
/// nobody is signed in.
class _MemoryTokenStore implements TokenStore {
  _MemoryTokenStore([this.tokens]);

  AuthTokens? tokens;
  int clears = 0;

  @override
  Future<AuthTokens?> readTokens() async => tokens;

  @override
  Future<void> saveTokens(AuthTokens next) async {
    if (tokens == null) return;
    tokens = next;
  }

  @override
  Future<void> clear() async {
    tokens = null;
    clears++;
  }
}

const _old = AuthTokens(accessToken: 'old', refreshToken: 'r1');
const _fresh = AuthTokens(accessToken: 'new', refreshToken: 'r2');

void main() {
  late SessionEvents events;
  late List<String> refreshCalls;

  setUp(() {
    events = SessionEvents();
    refreshCalls = <String>[];
  });

  TokenRefreshCoordinator build(
    _MemoryTokenStore store,
    Future<AuthTokens> Function(String refreshToken) refresh, {
    int maxAttempts = 3,
  }) =>
      TokenRefreshCoordinator(
        store: store,
        events: events,
        refresh: (token) {
          refreshCalls.add(token);
          return refresh(token);
        },
        maxAttempts: maxAttempts,
      );

  test('concurrent callers share one refresh (refresh tokens are single use)',
      () async {
    final store = _MemoryTokenStore(_old);
    final gate = Completer<AuthTokens>();
    final coordinator = build(store, (_) => gate.future);

    final first = coordinator.recover(rejectedAccessToken: 'old');
    final second = coordinator.recover(rejectedAccessToken: 'old');
    gate.complete(_fresh);

    expect(await Future.wait([first, second]), ['new', 'new']);
    expect(refreshCalls, ['r1']);
    expect(store.tokens?.refreshToken, 'r2');
  });

  test('a request whose token was already rotated does not refresh again',
      () async {
    final store = _MemoryTokenStore(_fresh);
    final coordinator =
        build(store, (_) async => throw StateError('should not refresh'));

    expect(await coordinator.recover(rejectedAccessToken: 'old'), 'new');
    expect(refreshCalls, isEmpty);
  });

  test('a start-up refresh with no rejected token always refreshes', () async {
    final store = _MemoryTokenStore(_old);
    final coordinator = build(store, (_) async => _fresh);

    expect(await coordinator.recover(), 'new');
    expect(refreshCalls, ['r1']);
  });

  test('429 waits and retries with the same refresh token', () async {
    final store = _MemoryTokenStore(_old);
    var attempts = 0;
    final coordinator = build(store, (_) async {
      attempts++;
      if (attempts == 1) {
        throw ApiException('slow down',
            statusCode: 429, retryAfter: const Duration(milliseconds: 1));
      }
      return _fresh;
    });

    expect(await coordinator.recover(rejectedAccessToken: 'old'), 'new');
    expect(refreshCalls, ['r1', 'r1']);
    expect(store.clears, 0);
  });

  test('429 that keeps coming gives up and keeps the session', () async {
    final store = _MemoryTokenStore(_old);
    final coordinator = build(
      store,
      (_) async => throw ApiException('slow down',
          statusCode: 429, retryAfter: const Duration(milliseconds: 1)),
      maxAttempts: 2,
    );

    await expectLater(
      coordinator.recover(rejectedAccessToken: 'old'),
      throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 429)),
    );
    expect(refreshCalls, ['r1', 'r1']);
    expect(store.clears, 0);
    expect(store.tokens?.accessToken, 'old');
  });

  test('401 on refresh clears the session and announces it', () async {
    final store = _MemoryTokenStore(_old);
    final seen = <SessionEventType>[];
    final subscription = events.stream.listen((e) => seen.add(e.type));
    final coordinator = build(
      store,
      (_) async => throw ApiException('refresh token used', statusCode: 401),
    );

    await expectLater(
      coordinator.recover(rejectedAccessToken: 'old'),
      throwsA(isA<ApiException>()),
    );
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(store.tokens, isNull);
    expect(store.clears, 1);
    expect(seen, [SessionEventType.expired]);
  });

  test('a network error keeps the session, so cached data still works',
      () async {
    final store = _MemoryTokenStore(_old);
    final coordinator = build(
      store,
      (_) async =>
          throw NetworkException('offline', kind: NetworkFailureKind.offline),
    );

    await expectLater(
      coordinator.recover(rejectedAccessToken: 'old'),
      throwsA(isA<NetworkException>()),
    );
    expect(store.clears, 0);
    expect(store.tokens?.accessToken, 'old');
  });
}
