import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/network/api_client.dart';
import 'package:healthylife_ai/core/network/app_version_interceptor.dart';
import 'package:healthylife_ai/core/network/auth_interceptor.dart';
import 'package:healthylife_ai/core/network/auth_tokens.dart';
import 'package:healthylife_ai/core/network/session_events.dart';
import 'package:healthylife_ai/core/network/token_refresh_coordinator.dart';
import 'package:healthylife_ai/core/network/token_store.dart';

class _MemoryTokenStore implements TokenStore {
  _MemoryTokenStore(this.tokens);

  AuthTokens? tokens;

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
  }
}

/// Answers each request from a script and records what was sent.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._respond);

  final ResponseBody Function(RequestOptions options) _respond;
  final List<RequestOptions> seen = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    seen.add(options);
    return _respond(options);
  }

  @override
  void close({bool force = false}) {}
}

const _old = AuthTokens(accessToken: 'old', refreshToken: 'r1');
const _fresh = AuthTokens(accessToken: 'new', refreshToken: 'r2');

ResponseBody json(int status, Map<String, dynamic> body) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

/// Rejects the old access token, accepts anything else.
ResponseBody rejectOld(RequestOptions options) =>
    options.headers['Authorization'] == 'Bearer old'
        ? json(401, {'message': 'expired'})
        : json(200, {'ok': true});

/// A Dio client wired exactly like the app's: the auth interceptor on top of
/// a real token store and refresh coordinator, with a scripted network.
class _Rig {
  _Rig(
    ResponseBody Function(RequestOptions options) respond, {
    Future<AuthTokens> Function(String refreshToken)? refresh,
  })  : store = _MemoryTokenStore(_old),
        events = SessionEvents(),
        adapter = _ScriptedAdapter(respond) {
    final refreshOnce =
        refresh ?? (String _) => Future<AuthTokens>.value(_fresh);
    coordinator = TokenRefreshCoordinator(
      store: store,
      events: events,
      refresh: (token) {
        refreshCalls.add(token);
        return refreshOnce(token);
      },
    );
    dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1/'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(AuthInterceptor(
      dio: dio,
      store: store,
      coordinator: coordinator,
      events: events,
    ));
  }

  final _MemoryTokenStore store;
  final SessionEvents events;
  final _ScriptedAdapter adapter;
  final List<String> refreshCalls = [];
  late final TokenRefreshCoordinator coordinator;
  late final Dio dio;
}

void main() {
  group('426 app_update_required (audit MO-06)', () {
    ResponseBody tooOld(RequestOptions _) => json(426, {
          'code': 'app_update_required',
          'message': 'update',
          'store_url': 'https://play.example.test/app',
        });

    test('on a signed-in request it raises the event and keeps the session',
        () async {
      final rig = _Rig(tooOld);
      final seen = <SessionEvent>[];
      rig.events.stream.listen(seen.add);

      await expectLater(rig.dio.get<dynamic>('me/today'), throwsA(anything));
      await Future<void>.delayed(Duration.zero);

      expect(seen.single.type, SessionEventType.updateRequired);
      expect(seen.single.body['store_url'], 'https://play.example.test/app');
      expect(rig.store.tokens, isNotNull, reason: 'the session must stay');
      expect(rig.refreshCalls, isEmpty);
    });

    test('sign-in itself answers it, so it is raised there too', () async {
      final rig = _Rig(tooOld);
      final seen = <SessionEvent>[];
      rig.events.stream.listen(seen.add);

      await expectLater(
        rig.dio.post<dynamic>('auth/login',
            options: Options(extra: {kAuthRequiredKey: false})),
        throwsA(anything),
      );
      await Future<void>.delayed(Duration.zero);

      expect(seen.single.type, SessionEventType.updateRequired);
    });

    test('a 426 with another code is not an update request', () async {
      final rig = _Rig((_) => json(426, {'code': 'upgrade_to_tls'}));
      final seen = <SessionEvent>[];
      rig.events.stream.listen(seen.add);

      await expectLater(rig.dio.get<dynamic>('me/today'), throwsA(anything));
      await Future<void>.delayed(Duration.zero);

      expect(seen, isEmpty);
    });
  });

  group('version header (audit MO-06)', () {
    test('every request carries the version and the platform', () async {
      final adapter = _ScriptedAdapter((_) => json(200, {'ok': true}));
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1/'))
        ..httpClientAdapter = adapter;
      dio.interceptors.add(AppVersionInterceptor(version: () => '1.4.2+17'));

      await dio.get<dynamic>('me/today');

      expect(adapter.seen.single.headers['X-App-Version'], '1.4.2+17');
      expect(adapter.seen.single.headers['X-App-Platform'], 'android');
    });

    test('where the version cannot be read, no header is sent', () async {
      final adapter = _ScriptedAdapter((_) => json(200, {'ok': true}));
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1/'))
        ..httpClientAdapter = adapter;
      dio.interceptors.add(AppVersionInterceptor(version: () => null));

      await dio.get<dynamic>('me/today');

      expect(adapter.seen.single.headers.containsKey('X-App-Version'), isFalse);
    });
  });

  group('bearer token', () {
    test('a signed-in request carries the access token', () async {
      final rig = _Rig((_) => json(200, {'ok': true}));

      await rig.dio.get<dynamic>('me');

      expect(rig.adapter.seen.single.headers['Authorization'], 'Bearer old');
    });

    test('login, refresh and logout are sent without a token', () async {
      final rig = _Rig((_) => json(200, {'ok': true}));

      await rig.dio.post<dynamic>(
        'auth/login',
        options: Options(extra: {kAuthRequiredKey: false}),
      );

      expect(rig.adapter.seen.single.headers.containsKey('Authorization'),
          isFalse);
    });
  });

  group('401 recovery', () {
    test('a file upload is replayed after the refresh', () async {
      // A multipart body can be sent once only; the replay needs its own
      // copy, or a report uploaded with an expired token fails as "offline".
      final rig = _Rig(rejectOld);

      final response = await rig.dio.post<dynamic>(
        'me/reports',
        data: FormData.fromMap({
          'title': 'CBC',
          'file': MultipartFile.fromBytes([1, 2, 3], filename: 'cbc.pdf'),
        }),
      );

      expect(response.statusCode, 200);
      expect(rig.refreshCalls, ['r1']);
      expect(rig.adapter.seen, hasLength(2));
      expect(rig.adapter.seen.last.headers['Authorization'], 'Bearer new');
      expect(rig.adapter.seen.last.data, isA<FormData>());
    });

    test('a 401 refreshes once and replays the request with the new token',
        () async {
      final rig = _Rig(rejectOld);

      final response = await rig.dio.get<dynamic>('me');

      expect(response.data, {'ok': true});
      expect(rig.refreshCalls, ['r1']);
      expect(rig.adapter.seen, hasLength(2));
      expect(rig.adapter.seen.last.headers['Authorization'], 'Bearer new');
    });

    test('a 401 that survives the replay is returned, not retried again',
        () async {
      final rig = _Rig((_) => json(401, {'message': 'nope'}));

      await expectLater(
        rig.dio.get<dynamic>('me'),
        throwsA(isA<DioException>()
            .having((e) => e.response?.statusCode, 'status', 401)),
      );
      expect(rig.adapter.seen, hasLength(2));
      expect(rig.refreshCalls, hasLength(1));
    });

    test('concurrent 401s share one refresh', () async {
      final rig = _Rig(
        rejectOld,
        refresh: (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 5));
          return _fresh;
        },
      );

      final responses = await Future.wait([
        rig.dio.get<dynamic>('a'),
        rig.dio.get<dynamic>('b'),
        rig.dio.get<dynamic>('c'),
      ]);

      expect(responses.map((r) => r.data), everyElement({'ok': true}));
      expect(rig.refreshCalls, hasLength(1));
    });

    test('a rejected refresh ends the session and fails the request', () async {
      final rig = _Rig(
        rejectOld,
        refresh: (_) async =>
            throw const ApiException('refresh token used', statusCode: 401),
      );
      final seen = <SessionEventType>[];
      final subscription = rig.events.stream.listen((e) => seen.add(e.type));

      await expectLater(
        rig.dio.get<dynamic>('me'),
        throwsA(isA<DioException>()
            .having((e) => e.error, 'error', isA<ApiException>())),
      );
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(rig.store.tokens, isNull);
      expect(seen, [SessionEventType.expired]);
    });

    test('a 401 on login is not refreshed; the caller gets the error',
        () async {
      final rig = _Rig((_) => json(401, {'message': 'wrong password'}));

      await expectLater(
        rig.dio.post<dynamic>(
          'auth/login',
          options: Options(extra: {kAuthRequiredKey: false}),
        ),
        throwsA(isA<DioException>()),
      );
      expect(rig.refreshCalls, isEmpty);
    });
  });

  group('session-ending and consent responses', () {
    test('403 follow_up_ended clears the session and reports the body',
        () async {
      final rig = _Rig((_) => json(403, {
            'code': 'follow_up_ended',
            'message': 'ended',
            'weeks_followed': 12,
          }));
      final seen = <SessionEvent>[];
      final subscription = rig.events.stream.listen(seen.add);

      await expectLater(
        rig.dio.get<dynamic>('me'),
        throwsA(isA<DioException>()),
      );
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(rig.store.tokens, isNull);
      expect(seen.single.type, SessionEventType.followUpEnded);
      expect(seen.single.body['weeks_followed'], 12);
    });

    test('403 consent_required keeps the session and reports the policy',
        () async {
      final rig = _Rig((_) => json(403, {
            'code': 'consent_required',
            'current_version': 'v2',
            'policy_url': 'https://example.test/privacy',
          }));
      final seen = <SessionEvent>[];
      final subscription = rig.events.stream.listen(seen.add);

      await expectLater(
        rig.dio.get<dynamic>('me'),
        throwsA(isA<DioException>()),
      );
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(rig.store.tokens?.accessToken, 'old');
      expect(seen.single.type, SessionEventType.consentRequired);
      expect(seen.single.body['current_version'], 'v2');
    });

    test('any other 403 changes nothing', () async {
      final rig = _Rig((_) => json(403, {'code': 'forbidden'}));
      final seen = <SessionEvent>[];
      final subscription = rig.events.stream.listen(seen.add);

      await expectLater(
        rig.dio.get<dynamic>('me'),
        throwsA(isA<DioException>()),
      );
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(rig.store.tokens?.accessToken, 'old');
      expect(seen, isEmpty);
    });
  });
}
