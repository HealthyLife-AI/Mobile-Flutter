import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/network/api_client.dart';
import 'package:healthylife_ai/core/storage/storage_service.dart';
import 'package:healthylife_ai/core/sync/offline_queue.dart';
import 'package:healthylife_ai/core/sync/pending_write.dart';
import 'package:healthylife_ai/core/sync/sync_policy.dart';

/// Answers each POST from [script]: null means saved, an exception is thrown.
/// Calls past the end of the script are saved. Every call is recorded.
class _ScriptedApi implements ApiClient {
  final List<AppException?> script = [];
  final List<({String path, Map<String, dynamic> body})> posts = [];

  @override
  Future<dynamic> post(String path, {Object? body, bool auth = true}) async {
    posts.add((
      path: path,
      body: body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{},
    ));
    final next = script.isEmpty ? null : script.removeAt(0);
    if (next != null) throw next;
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
  late _ScriptedApi api;
  late DateTime now;
  late List<Duration> pauses;

  setUp(() {
    storage = MemoryStorageService();
    api = _ScriptedApi();
    now = DateTime.utc(2026, 10, 7, 9);
    pauses = [];
  });

  OfflineQueue queueFor({void Function(DroppedWrite write)? onDropped}) =>
      OfflineQueue(
        storage: storage,
        api: api,
        clock: () => now,
        pause: (delay) async => pauses.add(delay),
        onDropped: onDropped,
      );

  test('sends queued writes in creation order and empties the queue', () async {
    final queue = queueFor();
    await queue.enqueue(path: 'me/measurements', body: {'weight_kg': 80});
    await queue.enqueue(path: 'me/measurements', body: {'weight_kg': 81});

    final report = await queue.flush();

    expect(report.sent, 2);
    expect(report.halt, isNull);
    expect(api.posts.map((p) => p.body['weight_kg']), [80, 81]);
    expect(await queue.pendingCount(), 0);
  });

  test('a lost connection keeps the write and waits for the backoff', () async {
    final queue = queueFor();
    await queue.enqueue(path: 'me/measurements', body: {'weight_kg': 80});
    api.script
        .add(NetworkException('offline', kind: NetworkFailureKind.offline));

    final first = await queue.flush();

    expect(first.halt, QueueHalt.waitingForRetry);
    expect(first.retryAt, now.add(const Duration(seconds: 2)));
    expect(await queue.pendingCount(), 1);

    // Too early: nothing is sent.
    final early = await queue.flush();
    expect(early.halt, QueueHalt.waitingForRetry);
    expect(api.posts, hasLength(1));

    now = now.add(const Duration(seconds: 2));
    final later = await queue.flush();
    expect(later.sent, 1);
    expect(api.posts, hasLength(2));
    expect(await queue.pendingCount(), 0);
  });

  test('a write refused as too old is dropped and reported, and the rest go',
      () async {
    final queue = queueFor();
    await queue.enqueue(path: 'me/measurements', body: {'weight_kg': 80});
    await queue.enqueue(path: 'me/measurements', body: {'weight_kg': 81});
    api.script.addAll([
      ApiException('old', statusCode: 422, code: 'entry_too_old'),
      null,
    ]);

    final report = await queue.flush();

    expect(report.sent, 1);
    expect(report.dropped.single.reason, DropReason.tooOld);
    expect(report.dropped.single.path, 'me/measurements');
    expect(await queue.pendingCount(), 0);
  });

  test('a removed meal item is sent once more without it, with the same key',
      () async {
    final queue = queueFor();
    await queue.enqueue(path: 'me/meal-logs', body: {
      'food_id': 3,
      'meal_item_id': 55,
      'idempotency_key': 'k-1',
    });
    api.script.addAll([
      ApiException('invalid', statusCode: 422, body: {
        'errors': {
          'meal_item_id': ['not on the plan']
        },
      }),
      null,
    ]);

    final report = await queue.flush();

    expect(report.sent, 1);
    expect(api.posts, hasLength(2));
    expect(api.posts.last.body, {'food_id': 3, 'idempotency_key': 'k-1'});
  });

  test('a removed meal item refused again is dropped as rejected', () async {
    final queue = queueFor();
    await queue.enqueue(path: 'me/meal-logs', body: {
      'food_id': 3,
      'meal_item_id': 55,
      'idempotency_key': 'k-1',
    });
    final refusal = ApiException('invalid', statusCode: 422, body: {
      'errors': {
        'meal_item_id': ['not on the plan']
      },
    });
    api.script.addAll([refusal, refusal]);

    final report = await queue.flush();

    expect(report.sent, 0);
    expect(report.dropped.single.reason, DropReason.rejected);
    expect(api.posts, hasLength(2));
    expect(await queue.pendingCount(), 0);
  });

  test('a future time on a write just made is sent without it', () async {
    final queue = queueFor();
    await queue.enqueue(path: 'me/meal-logs', body: {
      'food_id': 3,
      'logged_at': '2026-10-07T10:35:00.000Z',
      'idempotency_key': 'k-2',
    });
    api.script.addAll([
      ApiException('future', statusCode: 422, body: {
        'errors': {
          'logged_at': ['must not be in the future']
        },
      }),
      null,
    ]);

    final report = await queue.flush();

    expect(report.sent, 1);
    expect(api.posts.last.body, {'food_id': 3, 'idempotency_key': 'k-2'});
  });

  test('a future time on an old write is dropped as a clock problem', () async {
    final queue = queueFor();
    await queue.enqueue(path: 'me/meal-logs', body: {
      'food_id': 3,
      'logged_at': '2026-10-07T10:35:00.000Z',
    });
    now = now.add(const Duration(hours: 1));
    api.script.add(ApiException('future', statusCode: 422, body: {
      'errors': {
        'logged_at': ['must not be in the future']
      },
    }));

    final report = await queue.flush();

    expect(report.sent, 0);
    expect(report.dropped.single.reason, DropReason.clockAhead);
  });

  test('a refused write is also reported to onDropped', () async {
    final reported = <DroppedWrite>[];
    final queue = queueFor(onDropped: reported.add);
    await queue.enqueue(path: 'me/measurements', body: {'weight_kg': 80});
    api.script.add(ApiException('old', statusCode: 422, code: 'entry_too_old'));

    await queue.flush();

    expect(reported.single.reason, DropReason.tooOld);
    expect(reported.single.path, 'me/measurements');
  });

  test('a failing notice does not stop the queue from going on', () async {
    final queue = queueFor(onDropped: (_) => throw StateError('no screen'));
    await queue.enqueue(path: 'me/measurements', body: {'weight_kg': 80});
    await queue.enqueue(path: 'me/measurements', body: {'weight_kg': 81});
    api.script.addAll([
      ApiException('old', statusCode: 422, code: 'entry_too_old'),
      null,
    ]);

    final report = await queue.flush();

    expect(report.sent, 1);
    expect(await queue.pendingCount(), 0);
  });

  test('consent_required pauses the queue and keeps the write', () async {
    final queue = queueFor();
    await queue.enqueue(path: 'me/measurements', body: {'weight_kg': 80});
    api.script.add(
        ApiException('consent', statusCode: 403, code: 'consent_required'));

    final report = await queue.flush();

    expect(report.halt, QueueHalt.consentRequired);
    expect(report.sent, 0);
    expect(await queue.pendingCount(), 1);
  });

  test('follow_up_ended stops the queue and keeps the write', () async {
    final queue = queueFor();
    await queue.enqueue(path: 'me/measurements', body: {'weight_kg': 80});
    api.script
        .add(ApiException('ended', statusCode: 403, code: 'follow_up_ended'));

    final report = await queue.flush();

    expect(report.halt, QueueHalt.followUpEnded);
    expect(await queue.pendingCount(), 1);
  });

  test('a locked measurement is dropped and reported as locked', () async {
    final queue = queueFor();
    await queue.enqueue(path: 'me/measurements', body: {'weight_kg': 80});
    api.script.add(ApiException('locked', statusCode: 403, code: 'log_locked'));

    final report = await queue.flush();

    expect(report.dropped.single.reason, DropReason.locked);
    expect(await queue.pendingCount(), 0);
  });

  test('429 uses Retry-After for the next attempt', () async {
    final queue = queueFor();
    await queue.enqueue(path: 'me/measurements', body: {'weight_kg': 80});
    api.script.add(ApiException('slow down',
        statusCode: 429, retryAfter: const Duration(seconds: 30)));

    final report = await queue.flush();

    expect(report.halt, QueueHalt.waitingForRetry);
    expect(report.retryAt, now.add(const Duration(seconds: 30)));
  });

  test('repeated server errors back off further each time', () async {
    final queue = queueFor();
    await queue.enqueue(path: 'me/measurements', body: {'weight_kg': 80});
    api.script.add(ServerException('down', statusCode: 503));
    await queue.flush();

    now = now.add(const Duration(seconds: 2));
    api.script.add(ServerException('down', statusCode: 503));
    final second = await queue.flush();

    expect(second.retryAt, now.add(const Duration(seconds: 4)));
  });

  test('sends are paced by the minimum gap', () async {
    final queue = queueFor();
    for (var i = 0; i < 3; i++) {
      await queue.enqueue(path: 'me/measurements', body: {'weight_kg': 80 + i});
    }

    await queue.flush();

    expect(api.posts, hasLength(3));
    expect(pauses, [
      const Duration(milliseconds: 500),
      const Duration(milliseconds: 500),
    ]);
  });

  test('a flush during a flush shares its result and sends nothing twice',
      () async {
    final queue = queueFor();
    await queue.enqueue(path: 'me/measurements', body: {'weight_kg': 80});

    final first = queue.flush();
    final second = queue.flush();

    expect(identical(first, second), isTrue);
    await first;
    expect(api.posts, hasLength(1));
  });

  test('clear removes every queued write and the stored key', () async {
    final queue = queueFor();
    await queue.enqueue(path: 'me/measurements', body: {'weight_kg': 80});
    await queue.enqueue(path: 'me/measurements', body: {'weight_kg': 81});

    await queue.clear();

    expect(await queue.pendingCount(), 0);
    expect(await storage.containsKey(StorageKeys.pendingWrites), isFalse);
  });

  test('unreadable stored writes count as an empty queue', () async {
    await storage.writeString(StorageKeys.pendingWrites, 'not json');

    expect(await queueFor().pendingCount(), 0);
  });

  test('a stored write survives a round trip through JSON', () {
    final write = PendingWrite(
      id: 'a',
      path: 'me/meal-logs',
      body: const {'food_id': 3},
      queuedAt: DateTime.utc(2026, 10, 7, 9),
      attempts: 2,
      nextAttemptAt: DateTime.utc(2026, 10, 7, 9, 5),
      retriedWithout: const {'meal_item_id'},
    );

    final back = PendingWrite.fromJson(write.toJson())!;

    expect(back.id, 'a');
    expect(back.path, 'me/meal-logs');
    expect(back.body, {'food_id': 3});
    expect(back.queuedAt, write.queuedAt);
    expect(back.attempts, 2);
    expect(back.nextAttemptAt, write.nextAttemptAt);
    expect(back.retriedWithout, {'meal_item_id'});
    expect(PendingWrite.fromJson({'id': 'x'}), isNull);
  });
}
