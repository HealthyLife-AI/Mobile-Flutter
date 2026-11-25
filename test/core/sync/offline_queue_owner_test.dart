import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/network/api_client.dart';
import 'package:healthylife_ai/core/storage/storage_service.dart';
import 'package:healthylife_ai/core/sync/offline_queue.dart';
import 'package:healthylife_ai/core/sync/sync_policy.dart';

/// Audit MO-02: a meal or measurement logged offline is never lost because
/// the session ended (a refused refresh, the follow-up ending, signing out),
/// and is only ever sent under the patient who made it.
class _Api implements ApiClient {
  final List<AppException?> script = [];
  final List<Map<String, dynamic>> sent = [];

  @override
  Future<dynamic> post(String path, {Object? body, bool auth = true}) async {
    final next = script.isEmpty ? null : script.removeAt(0);
    if (next != null) throw next;
    sent.add(Map<String, dynamic>.from(body as Map));
    return null;
  }

  @override
  Future<dynamic> get(String path,
          {Map<String, dynamic>? query, bool auth = true}) =>
      throw UnimplementedError(path);

  @override
  Future<dynamic> put(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);

  @override
  Future<dynamic> patch(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);

  @override
  Future<dynamic> delete(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);
}

void main() {
  late MemoryStorageService storage;
  late _Api api;
  String? signedIn;

  OfflineQueue queue() => OfflineQueue(
        storage: storage,
        api: api,
        pause: (_) async {},
        currentOwner: () async => signedIn,
      );

  setUp(() {
    storage = MemoryStorageService();
    api = _Api();
    signedIn = '7';
  });

  Map<String, dynamic> log(String key) => {'idempotency_key': key};

  test('ending the session keeps the write', () async {
    final q = queue();
    await q.enqueue(path: 'me/meal-logs', body: log('a'));

    // What a refused refresh, the follow-up ending or signing out runs.
    await q.forgetPatientData();
    signedIn = null;

    expect((await storage.readMap(StorageKeys.pendingWrites))?['items'],
        hasLength(1));
  });

  test('nothing is sent while signed out', () async {
    final q = queue();
    await q.enqueue(path: 'me/meal-logs', body: log('a'));
    signedIn = null;

    final report = await q.flush();

    expect(report.halt, QueueHalt.unauthorized);
    expect(api.sent, isEmpty);
  });

  test('a rejected refresh, then the same patient signs in: sent once',
      () async {
    final q = queue();
    await q.enqueue(path: 'me/meal-logs', body: log('a'));
    api.script.add(const ApiException('expired', statusCode: 401));
    expect((await q.flush()).halt, QueueHalt.unauthorized);
    await q.forgetPatientData();
    signedIn = null;

    signedIn = '7';
    final report = await q.flush();

    expect(report.sent, 1);
    expect(api.sent.single['idempotency_key'], 'a');
    expect(await q.pendingCount(), 0);
  });

  test(
      'another patient on the phone never sends or sees the first patient\'s writes',
      () async {
    final q = queue();
    await q.enqueue(path: 'me/meal-logs', body: log('mine'));
    await q.forgetPatientData();

    signedIn = '8';
    await q.enqueue(path: 'me/meal-logs', body: log('theirs'));
    expect(await q.pendingCount(), 1);
    expect((await q.pendingWrites()).single.body['idempotency_key'], 'theirs');

    await q.flush();
    expect(api.sent.map((b) => b['idempotency_key']), ['theirs']);

    // The first patient comes back: their write goes out under their session.
    signedIn = '7';
    await q.flush();
    expect(api.sent.map((b) => b['idempotency_key']), ['theirs', 'mine']);
  });

  test('a write an older build stored (no owner) is the signed-in patient\'s',
      () async {
    await storage.writeMap(StorageKeys.pendingWrites, {
      'items': [
        {
          'id': '1',
          'path': 'me/meal-logs',
          'body': log('legacy'),
          'queuedAt': DateTime.utc(2026, 11, 20).toIso8601String(),
        },
      ],
    });

    final report = await queue().flush();

    expect(report.sent, 1);
    expect(api.sent.single['idempotency_key'], 'legacy');
  });

  test('deleting the account drops that patient\'s writes and keeps others\'',
      () async {
    final q = queue();
    await q.enqueue(path: 'me/meal-logs', body: log('mine'));
    signedIn = '8';
    await q.enqueue(path: 'me/meal-logs', body: log('theirs'));

    await q.forgetOwner('7');

    signedIn = '7';
    expect(await q.pendingCount(), 0);
    signedIn = '8';
    expect(await q.pendingCount(), 1);
  });
}
