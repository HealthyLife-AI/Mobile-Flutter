// Audit (pre-launch 2026-11), invariant I2 (app side): the real meal-log data
// layer (MealLogRepositoryImpl + OfflineQueue + session + Dio auth stack)
// against a LIVE local backend. Skipped unless AUDIT_API is set:
//   AUDIT_API=http://127.0.0.1:8000/api/v1 flutter test \
//     --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1 test/audit/meal_log_queue_live_test.dart
// Creates its own nutritionist and patients through the public API.
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/network/api_client.dart';
import 'package:healthylife_ai/core/network/api_client_factory.dart';
import 'package:healthylife_ai/core/network/session_events.dart';
import 'package:healthylife_ai/core/network/token_refresh_coordinator.dart';
import 'package:healthylife_ai/core/storage/patient_cache.dart';
import 'package:healthylife_ai/core/storage/secure_vault.dart';
import 'package:healthylife_ai/core/storage/storage_service.dart';
import 'package:healthylife_ai/core/sync/offline_queue.dart';
import 'package:healthylife_ai/core/time/date_only.dart';
import 'package:healthylife_ai/data/datasources/session_local_data_source.dart';
import 'package:healthylife_ai/data/models/auth_dto.dart';
import 'package:healthylife_ai/data/repositories/meal_log_repository_impl.dart';
import 'package:healthylife_ai/domain/entities/auth_entities.dart';
import 'package:healthylife_ai/domain/entities/meal_entities.dart';

final String? _base = Platform.environment['AUDIT_API'];

/// Raw HTTP for test setup (nutritionist side and checks), outside the app.
final Dio _raw = Dio(BaseOptions(
  baseUrl: '${_base ?? 'http://127.0.0.1:8000/api/v1'}/',
  headers: {'Accept': 'application/json'},
  validateStatus: (_) => true,
));

Future<Map<String, dynamic>> _post(String path, Object? body,
    [String? token]) async {
  final r = await _raw.post<dynamic>(path,
      data: body,
      options: Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'}));
  return {'status': r.statusCode, 'body': r.data};
}

Future<Map<String, dynamic>> _get(String path, String token,
    [Map<String, dynamic>? q]) async {
  final r = await _raw.get<dynamic>(path,
      queryParameters: q,
      options: Options(headers: {'Authorization': 'Bearer $token'}));
  return {'status': r.statusCode, 'body': r.data};
}

late String _nutritionistToken;
int _n = 0;

class _Patient {
  _Patient(this.subscriberId, this.username, this.password);
  final int subscriberId;
  final String username;
  String password;
}

Future<_Patient> _newPatient() async {
  final stamp = DateTime.now().microsecondsSinceEpoch.toString();
  final c = await _post(
      'clients',
      {
        'name': 'Queue Patient ${_n++}',
        'phone': '+97059${stamp.substring(stamp.length - 7)}',
        'goal': 'weight_loss'
      },
      _nutritionistToken);
  expect(c['status'], 201, reason: '${c['body']}');
  final b = c['body'] as Map;
  final p = _Patient(b['client']['id'] as int,
      b['credentials']['username'] as String, b['credentials']['password'] as String);
  // Consent once, so the queue is not halted by consent_required.
  final login = await _login(p);
  final consent = await _get('me/consent', login['access_token'] as String);
  await _post('me/consent', {'version': (consent['body'] as Map)['current_version']},
      login['access_token'] as String);
  return p;
}

Future<Map<String, dynamic>> _login(_Patient p) async {
  final r = await _post('auth/login', {'username': p.username, 'password': p.password});
  expect(r['status'], 200, reason: '${r['body']}');
  return Map<String, dynamic>.from(r['body'] as Map);
}

Future<int> _serverLogCount(_Patient p) async {
  final t = (await _login(p))['access_token'] as String;
  final r = await _get('me/meal-logs', t);
  return ((r['body'] as Map)['meta'] as Map)['total'] as int;
}

/// Switchable transport in front of the app's real client: offline, or
/// "the request reaches the server but the answer is lost".
class _Line implements ApiClient {
  _Line(this.real);
  final ApiClient real;
  bool offline = false;
  bool loseNextResponse = false;

  Future<dynamic> _go(Future<dynamic> Function() send) async {
    if (offline) {
      throw const NetworkException('offline', kind: NetworkFailureKind.offline);
    }
    final result = await send();
    if (loseNextResponse) {
      loseNextResponse = false;
      throw const NetworkException('answer lost', kind: NetworkFailureKind.timeout);
    }
    return result;
  }

  @override
  Future get(String path, {Map<String, dynamic>? query, bool auth = true}) =>
      _go(() => real.get(path, query: query, auth: auth));
  @override
  Future post(String path, {Object? body, bool auth = true}) =>
      _go(() => real.post(path, body: body, auth: auth));
  @override
  Future put(String path, {Object? body, bool auth = true}) =>
      _go(() => real.put(path, body: body, auth: auth));
  @override
  Future patch(String path, {Object? body, bool auth = true}) =>
      _go(() => real.patch(path, body: body, auth: auth));
  @override
  Future delete(String path, {Object? body, bool auth = true}) =>
      _go(() => real.delete(path, body: body, auth: auth));
}

/// One installed app: storage that survives "restarts", the real session,
/// refresh coordinator, Dio stack, queue and meal-log repository.
class _Device {
  _Device({StorageService? storage, SecureVault? vault})
      : storage = storage ?? MemoryStorageService(),
        vault = vault ?? MemorySecureVault() {
    session = SessionLocalDataSource(this.vault,
        onCleared: () => forgetPatientCaches([queue, repo]));
    final coordinator = TokenRefreshCoordinator(
      store: session,
      events: events,
      refresh: (rt) async => AuthMapper.tokensFromJson(
          await realApi.post('auth/refresh', body: {'refresh_token': rt}, auth: false)),
    );
    realApi = createApiClient(
        store: session, coordinator: coordinator, events: events, baseUrl: _base);
    line = _Line(realApi);
    queue = OfflineQueue(
        storage: this.storage,
        api: line,
        minGap: Duration.zero,
        onSaved: (w, r) => repo.recordSaved(w, r));
    repo = MealLogRepositoryImpl(this.storage, queue, line);
    events.stream.listen(seen.add);
  }

  final StorageService storage;
  final SecureVault vault;
  final SessionEvents events = SessionEvents();
  final List<SessionEvent> seen = [];
  late final SessionLocalDataSource session;
  late final ApiClient realApi;
  late final _Line line;
  late final OfflineQueue queue;
  late final MealLogRepositoryImpl repo;

  Future<void> signIn(_Patient p) async {
    final s = AuthMapper.signedInFromJson(await _login(p));
    await session.save(StoredSession(tokens: s.tokens, user: s.user));
  }
}

const _bread = SearchableFood(
    name: 'خبز عربي', caloriesPer100g: 275, macro: 'carbs', id: 36);

void main() {
  final skip = _base == null ? 'set AUDIT_API to run against a live API' : null;

  setUpAll(() async {
    if (_base == null) return;
    final stamp = DateTime.now().millisecondsSinceEpoch;
    const pw = 'QueueAudit2026x';
    final r = await _post('auth/register', {
      'name': 'Queue Audit Nutritionist',
      'email': 'queue$stamp@example.test',
      'password': pw,
      'password_confirmation': pw,
    });
    expect(r['status'], anyOf(200, 201), reason: '${r['body']}');
    _nutritionistToken = (r['body'] as Map)['access_token'] as String;
  });

  test('offline log survives an app restart and is sent exactly once',
      () async {
    final p = await _newPatient();
    final storage = MemoryStorageService();
    final vault = MemorySecureVault();
    final a = _Device(storage: storage, vault: vault);
    await a.signIn(p);
    a.line.offline = true;
    final logged = await a.repo.logFood(_bread, grams: 80);
    expect(logged.isSuccess, isTrue);
    expect(await a.queue.pendingCount(), 1);

    // "Restart": a new process over the same persisted storage and vault.
    final b = _Device(storage: storage, vault: vault);
    expect(await b.queue.pendingCount(), 1, reason: 'queue persisted');
    await Future<void>.delayed(const Duration(seconds: 3)); // offline backoff
    final report = await b.queue.flush();
    expect(report.sent, 1);
    expect(await _serverLogCount(p), 1);
  }, skip: skip);

  test('request reaches the server, answer lost, replay -> still one log',
      () async {
    final p = await _newPatient();
    final d = _Device();
    await d.signIn(p);
    d.line.loseNextResponse = true;
    await d.repo.logFood(_bread, grams: 80); // flush inside: answer lost
    expect(await d.queue.pendingCount(), 1, reason: 'kept after lost answer');
    // backoff: make the head due now
    final again = _Device(storage: d.storage, vault: d.vault);
    await Future<void>.delayed(const Duration(seconds: 3));
    await again.queue.flush();
    expect(await again.queue.pendingCount(), 0);
    expect(await _serverLogCount(p), 1, reason: 'idempotency key per meal');
  }, skip: skip);

  test('expired/invalid access token during replay -> refresh + retry',
      () async {
    final p = await _newPatient();
    final d = _Device();
    await d.signIn(p);
    d.line.offline = true;
    await d.repo.logFood(_bread, grams: 80);
    final s = (await d.session.read())!;
    // A well-formed JWT the server refuses (signature changed) stands in for
    // an expired one. NB: a malformed 3-part token answers 500, not 401
    // (firebase/php-jwt DomainException) and the queue then waits forever.
    final at = s.tokens.accessToken;
    await d.session.saveTokens(AuthMapper.tokensFromJson({
      'access_token': '${at.substring(0, at.length - 2)}${at.endsWith('AA') ? 'BB' : 'AA'}',
      'refresh_token': s.tokens.refreshToken,
      'expires_in': 900,
    }));
    d.line.offline = false;
    await Future<void>.delayed(const Duration(seconds: 3)); // offline backoff
    final r = await d.queue.flush();
    expect(r.sent, 1);
    expect(await _serverLogCount(p), 1);
  }, skip: skip);

  test(
      'DATA LOSS: nutritionist resets the password (WhatsApp flow) while a meal '
      'is queued -> refresh 401 -> session cleared -> queued meal deleted',
      () async {
    final p = await _newPatient();
    final d = _Device();
    await d.signIn(p);
    d.line.offline = true;
    await d.repo.logFood(_bread, grams: 80);
    expect(await d.queue.pendingCount(), 1);

    final reset = await _post(
        'clients/${p.subscriberId}/reset-password', {}, _nutritionistToken);
    expect(reset['status'], anyOf(200, 201), reason: '${reset['body']}');
    p.password = ((reset['body'] as Map)['credentials'] ??
        reset['body'])['password'] as String;

    d.line.offline = false;
    await Future<void>.delayed(const Duration(seconds: 3)); // offline backoff
    final r = await d.queue.flush();
    // ignore: avoid_print
    print('flush after reset: sent=${r.sent} halt=${r.halt} '
        'pending=${await d.queue.pendingCount()} events=${d.seen.map((e) => e.type)}');
    // The patient signs in again with the new password on the same phone.
    await d.signIn(p);
    await d.queue.flush();
    expect(await _serverLogCount(p), 1,
        reason: 'the meal logged offline before the reset never reaches the server');
  }, skip: skip);

  test(
      'DATA LOSS: refresh answer lost, app killed, reopened after the 30 s grace '
      '-> reuse detection revokes every session (both phones) and wipes the queue',
      () async {
    final p = await _newPatient();
    final phoneA = _Device();
    final phoneB = _Device();
    await phoneA.signIn(p);
    await phoneB.signIn(p);
    // Phone A: the refresh reaches the server (rotated), answer lost, killed.
    final old = (await phoneA.session.read())!.tokens;
    final rotated = await _post('auth/refresh', {'refresh_token': old.refreshToken});
    expect(rotated['status'], 200);
    // Meanwhile both phones log offline.
    phoneA.line.offline = true;
    phoneB.line.offline = true;
    await phoneA.repo.logFood(_bread, grams: 50);
    await phoneB.repo.logFood(_bread, grams: 70);
    await Future<void>.delayed(const Duration(seconds: 33));
    // Phone A reopens with an expired access token and the old refresh token.
    await phoneA.session.saveTokens(AuthMapper.tokensFromJson({
      'access_token': 'expired', 'refresh_token': old.refreshToken, 'expires_in': 900}));
    phoneA.line.offline = false;
    final ra = await phoneA.queue.flush();
    // Phone B's access token is still valid for <15 min; force its refresh too.
    final sb = (await phoneB.session.read())!.tokens;
    await phoneB.session.saveTokens(AuthMapper.tokensFromJson({
      'access_token': 'expired', 'refresh_token': sb.refreshToken, 'expires_in': 900}));
    phoneB.line.offline = false;
    final rb = await phoneB.queue.flush();
    // ignore: avoid_print
    print('A: sent=${ra.sent} halt=${ra.halt} pending=${await phoneA.queue.pendingCount()} '
        'signedIn=${await phoneA.session.read() != null} | '
        'B: sent=${rb.sent} halt=${rb.halt} pending=${await phoneB.queue.pendingCount()} '
        'signedIn=${await phoneB.session.read() != null}');
    expect(await _serverLogCount(p), 2,
        reason: 'both offline meals should survive a forced re-login');
  }, skip: skip, timeout: const Timeout(Duration(minutes: 2)));

  test('double tap on "log" while the line is slow -> duplicate logs?',
      () async {
    final p = await _newPatient();
    final d = _Device();
    await d.signIn(p);
    // Two taps on the same off-plan food, the second before the first's
    // flush has answered (repository level; the cubit has no busy guard).
    await Future.wait([
      d.repo.logFood(_bread, grams: 80),
      d.repo.logFood(_bread, grams: 80),
    ]);
    await d.queue.flush();
    // ignore: avoid_print
    print('server logs after double tap: ${await _serverLogCount(p)}');
  }, skip: skip);

  // I5: run with TZ=Asia/Gaza and TZ=Asia/Aden. 2026-11-20T21:30Z is 23:30 in
  // Gaza (UTC+2 in November) and 00:30 on 21 Nov in Aden (UTC+3).
  test('I5: which day the app shows vs which day the server records', () async {
    final p = await _newPatient();
    final instant = DateTime.utc(2026, 11, 20, 21, 30);
    final d = _Device();
    await d.signIn(p);
    final repo = MealLogRepositoryImpl(d.storage, d.queue, d.line,
        clock: () => instant.toLocal());
    final entry = (await repo.logFood(_bread, grams: 80)).valueOrNull!;
    await d.queue.flush();
    final appDay = dateOnly(entry.loggedAt.toLocal());
    final sent = await _get('clients/${p.subscriberId}/meal-logs/daily',
        _nutritionistToken, {'from': '2026-11-19', 'to': '2026-11-22'});
    final serverDays = [
      for (final day in (sent['body'] as Map)['days'] as List)
        if (((day as Map)['logs'] as List).isNotEmpty) day['date']
    ];
    // ignore: avoid_print
    print('TZ=${Platform.environment['TZ']} offset=${instant.toLocal().timeZoneOffset} '
        'device local=${instant.toLocal()} | app shows on $appDay | '
        'body sent logged_at=${instant.toIso8601String()} | server (SCHEDULE_TIMEZONE) day=$serverDays');
    expect(serverDays, [appDay],
        reason: 'the patient sees the meal on one day, the nutritionist on another');
  }, skip: skip);
}
