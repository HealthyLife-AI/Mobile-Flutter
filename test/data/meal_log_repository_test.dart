import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/core/network/api_client.dart';
import 'package:healthylife_ai/core/storage/storage_service.dart';
import 'package:healthylife_ai/core/sync/offline_queue.dart';
import 'package:healthylife_ai/data/repositories/meal_log_repository_impl.dart';
import 'package:healthylife_ai/domain/entities/meal_entities.dart';

import '../helpers/sample_meal_plan.dart';

/// Records each write. Each write takes the next answer: null saves it, an
/// [AppException] is thrown. When no answers are left, writes are saved. A
/// saved log comes back with the id 100 + its number, as the server answers
/// (6.1). Deletes take [deleteAnswers] the same way.
class _ScriptedApi implements ApiClient {
  final List<String> paths = [];
  final List<Map<String, dynamic>> bodies = [];
  final List<Object?> answers = [];
  final List<String> deletes = [];
  final List<Object?> deleteAnswers = [];

  @override
  Future<dynamic> post(String path, {Object? body, bool auth = true}) async {
    paths.add(path);
    bodies.add(Map<String, dynamic>.from(body as Map));
    final next = answers.isEmpty ? null : answers.removeAt(0);
    if (next is AppException) throw next;
    return {
      'id': 100 + paths.length,
      'editable_until': '2026-10-21T10:36:02+00:00',
    };
  }

  /// Each GET takes the next page; an [AppException] is thrown.
  final List<Object> pages = [];
  final List<Map<String, dynamic>?> queries = [];

  @override
  Future<dynamic> get(String path,
      {Map<String, dynamic>? query, bool auth = true}) async {
    queries.add(query);
    final next = pages.removeAt(0);
    if (next is AppException) throw next;
    return next;
  }

  @override
  Future<dynamic> put(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);

  /// Each PATCH takes the next answer; an [AppException] is thrown.
  final List<Object> patchAnswers = [];
  final List<({String path, Object? body})> patches = [];

  @override
  Future<dynamic> patch(String path, {Object? body, bool auth = true}) async {
    patches.add((path: path, body: body));
    final next = patchAnswers.removeAt(0);
    if (next is AppException) throw next;
    return next;
  }

  @override
  Future<dynamic> delete(String path, {Object? body, bool auth = true}) async {
    deletes.add(path);
    final next = deleteAnswers.isEmpty ? null : deleteAnswers.removeAt(0);
    if (next is AppException) throw next;
    return null;
  }
}

const SearchableFood _rice =
    SearchableFood(name: 'Rice', caloriesPer100g: 130, macro: 'carb', id: 3);

const Meal _lunch = Meal(
  id: 'lunch-1',
  name: 'Lunch',
  timeRange: '12:00 - 13:00',
  calories: 520,
  items: [MealItem(name: 'Chicken', grams: 150)],
  alternativesText: '',
  status: MealStatus.current,
  iconEmojiSlot: 'lunch',
);

const NetworkException _offline =
    NetworkException('no connection', kind: NetworkFailureKind.offline);

void main() {
  late _ScriptedApi api;
  late MemoryStorageService storage;
  late OfflineQueue queue;
  late MealLogRepositoryImpl repository;
  late DateTime now;
  late int keysMade;

  setUp(() {
    now = DateTime(2026, 10, 14, 10, 35);
    keysMade = 0;
    api = _ScriptedApi();
    storage = MemoryStorageService();
    queue = OfflineQueue(
      storage: storage,
      api: api,
      clock: () => now,
      pause: (_) async {},
      onSaved: (write, response) => repository.recordSaved(write, response),
    );
    repository = MealLogRepositoryImpl(
      storage,
      queue,
      api,
      clock: () => now,
      newKey: () => 'key-${++keysMade}',
    );
  });

  test('an off-plan food with a server id is sent with its grams, time and key',
      () async {
    final result = await repository.logFood(_rice, grams: 250);

    expect(result.isSuccess, isTrue);
    expect(api.paths, ['me/meal-logs']);
    final body = api.bodies.single;
    expect(body['food_id'], 3);
    expect(body['quantity_grams'], 250);
    expect(body['logged_at'], now.toUtc().toIso8601String());
    expect(body['logged_at'], endsWith('Z'));
    expect(body['idempotency_key'], 'key-1');
    expect(body.containsKey('meal_item_id'), isFalse);
  });

  test('each log gets its own key', () async {
    await repository.logFood(_rice, grams: 100);
    await repository.logFood(_rice, grams: 100);

    expect(
        api.bodies.map((body) => body['idempotency_key']), ['key-1', 'key-2']);
  });

  test('a log made offline is kept, and sent later with the same key',
      () async {
    api.answers.add(_offline);

    final result = await repository.logFood(_rice, grams: 250);

    expect(result.isSuccess, isTrue);
    expect(await queue.pendingCount(), 1);

    now = now.add(const Duration(days: 1)); // the retry is due
    final report = await queue.flush();

    expect(report.sent, 1);
    expect(await queue.pendingCount(), 0);
    expect(
        api.bodies.map((body) => body['idempotency_key']), ['key-1', 'key-1']);
  });

  test(
      'an entry the server refuses as too old leaves the queue but stays on '
      'the device', () async {
    api.answers.add(
        const ApiException('too old', statusCode: 422, code: 'entry_too_old'));

    final result = await repository.logFood(_rice, grams: 250);

    expect(result.isSuccess, isTrue);
    expect(await queue.pendingCount(), 0);
    expect((await repository.getEntries()).valueOrNull?.single.name, 'Rice');
  });

  test('a food without a server id stays on the device only', () async {
    const homemade = SearchableFood(
        name: 'Homemade soup', caloriesPer100g: 60, macro: 'other');

    final result = await repository.logFood(homemade, grams: 300);

    expect(result.isSuccess, isTrue);
    expect(api.paths, isEmpty);
    expect(await queue.pendingCount(), 0);
    expect((await repository.getEntries()).valueOrNull?.single.calories, 180);
  });

  test('a meal that is not from the server plan is kept on the device only',
      () async {
    final result = await repository.logPlanned(_lunch);

    expect(result.valueOrNull?.isOffPlan, isFalse);
    expect(api.paths, isEmpty);
    expect(await queue.pendingCount(), 0);
  });

  group('a meal from the nutritionist plan (API guide 6.1)', () {
    test('sends each planned item with its meal_item_id, food and grams',
        () async {
      final lunch = sampleLunch();

      final result = await repository.logPlanned(lunch);

      expect(result.isSuccess, isTrue);
      expect(api.paths, ['me/meal-logs', 'me/meal-logs', 'me/meal-logs']);
      expect(api.bodies.map((b) => b['meal_item_id']), [60, 62, 64]);
      expect(api.bodies.map((b) => b['food_id']), [6, 8, 10]);
      expect(api.bodies.map((b) => b['quantity_grams']), [150, 120, 200]);
      expect(api.bodies.map((b) => b['idempotency_key']),
          ['key-1', 'key-2', 'key-3']);
      for (final body in api.bodies) {
        expect(body['logged_at'], now.toUtc().toIso8601String());
      }
      expect(result.valueOrNull!.calories, 422);
    });

    test('sends the alternative the patient picked instead of the item',
        () async {
      final lunch = sampleLunch();
      final items = lunch.source!.items;
      final fish = items[0].alternatives.single; // instead of chicken

      final result =
          await repository.logPlanned(lunch, eaten: [fish, items[1], items[2]]);

      expect(api.bodies.map((b) => b['meal_item_id']), [61, 62, 64]);
      expect(api.bodies.first['food_id'], 7);
      expect(api.bodies.first['quantity_grams'], 160);
      // Calories are what was eaten: fish 192 + rice 134 + salad 40.
      expect(result.valueOrNull!.calories, 366);
    });

    test('logged offline, the items wait in the queue with their keys',
        () async {
      api.answers.addAll([_offline, _offline, _offline]);

      final result = await repository.logPlanned(sampleLunch());

      expect(result.isSuccess, isTrue, reason: 'kept on the device');
      expect(await queue.pendingCount(), 3);
    });

    test('logging the same meal again today sends nothing more', () async {
      await repository.logPlanned(sampleLunch());
      await repository.logPlanned(sampleLunch());

      expect(api.paths, hasLength(3));
    });
  });

  test('a planned meal is logged once a day, and again on another day',
      () async {
    final first = (await repository.logPlanned(_lunch)).valueOrNull!;
    final again = (await repository.logPlanned(_lunch)).valueOrNull!;

    expect(again.id, first.id);
    expect((await repository.getEntries()).valueOrNull, hasLength(1));

    now = now.add(const Duration(days: 1));
    await repository.logPlanned(_lunch);

    expect((await repository.getEntries()).valueOrNull, hasLength(2));
  });

  group('deleting an entry (API guide 6.4)', () {
    Future<List<MealLogEntry>> entries() async =>
        (await repository.getEntries()).valueOrNull!;

    test('a saved food is deleted on the server and here', () async {
      final entry = (await repository.logFood(_rice, grams: 250)).valueOrNull!;

      final result = await repository.delete(entry.id);

      expect(result.isSuccess, isTrue);
      expect(api.deletes, ['me/meal-logs/101']);
      expect(await entries(), isEmpty);
    });

    test('a planned meal deletes each of its logs', () async {
      final entry = (await repository.logPlanned(sampleLunch())).valueOrNull!;

      await repository.delete(entry.id);

      expect(api.deletes,
          ['me/meal-logs/101', 'me/meal-logs/102', 'me/meal-logs/103']);
      expect(await entries(), isEmpty);
    });

    test('a log still waiting in the queue is taken out, never sent', () async {
      api.answers.add(_offline);
      final entry = (await repository.logFood(_rice, grams: 250)).valueOrNull!;
      expect(await queue.pendingCount(), 1);

      final result = await repository.delete(entry.id);

      expect(result.isSuccess, isTrue);
      expect(api.deletes, isEmpty);
      expect(await queue.pendingCount(), 0);
      now = now.add(const Duration(days: 1));
      await queue.flush();
      expect(api.paths, ['me/meal-logs'], reason: 'only the failed first try');
      expect(await entries(), isEmpty);
    });

    test('offline, the entry stays and can be deleted later', () async {
      final entry = (await repository.logFood(_rice, grams: 250)).valueOrNull!;
      api.deleteAnswers.add(_offline);

      final failed = await repository.delete(entry.id);

      expect(failed.failureOrNull, isA<NetworkFailure>());
      expect(await entries(), hasLength(1));

      final retried = await repository.delete(entry.id);

      expect(retried.isSuccess, isTrue);
      expect(api.deletes, ['me/meal-logs/101', 'me/meal-logs/101']);
      expect(await entries(), isEmpty);
    });

    test('a delete that stops half-way resumes where it stopped', () async {
      final entry = (await repository.logPlanned(sampleLunch())).valueOrNull!;
      api.deleteAnswers.addAll([null, _offline]);

      await repository.delete(entry.id);
      expect(await entries(), hasLength(1));

      await repository.delete(entry.id);

      expect(api.deletes, [
        'me/meal-logs/101',
        'me/meal-logs/102', // failed
        'me/meal-logs/102',
        'me/meal-logs/103',
      ]);
      expect(await entries(), isEmpty);
    });

    test('a log the server no longer has counts as deleted', () async {
      final entry = (await repository.logFood(_rice, grams: 250)).valueOrNull!;
      api.deleteAnswers.add(const NotFoundException('gone'));

      final result = await repository.delete(entry.id);

      expect(result.isSuccess, isTrue);
      expect(await entries(), isEmpty);
    });

    test('past the edit window the server refuses and the entry stays',
        () async {
      final entry = (await repository.logFood(_rice, grams: 250)).valueOrNull!;
      api.deleteAnswers.add(const ApiException('locked',
          statusCode: 403, code: 'log_locked', body: {'editable_days': 7}));

      final result = await repository.delete(entry.id);

      expect((result.failureOrNull as ApiFailure?)?.code, 'log_locked');
      expect(await entries(), hasLength(1));
    });

    test('the server ids survive a restart', () async {
      final entry = (await repository.logFood(_rice, grams: 250)).valueOrNull!;
      final restarted = MealLogRepositoryImpl(storage, queue, api);

      await restarted.delete(entry.id);

      expect(api.deletes, ['me/meal-logs/101']);
    });

    test('delete is offered only until editable_until', () async {
      final entry = (await repository.logFood(_rice, grams: 250)).valueOrNull!;
      final kept = (await entries()).single;

      expect(kept.id, entry.id);
      expect(kept.canDeleteAt(DateTime.utc(2026, 10, 21, 10, 36)), isTrue);
      expect(kept.canDeleteAt(DateTime.utc(2026, 10, 21, 10, 37)), isFalse);
    });
  });

  group('reading the server\'s logs (6.2) and changing grams (6.3)', () {
    Future<List<MealLogEntry>> entries() async =>
        (await repository.getEntries()).valueOrNull!;

    Map<String, dynamic> serverLog(int id,
            {int grams = 100, double calories = 130}) =>
        {
          'id': id,
          'food': {'id': 3, 'name_en': 'Rice', 'name_ar': 'أرز'},
          'quantity_grams': grams,
          'macros': {'calories': calories},
          'meal_item_id': null,
          'meal_type': 'snack',
          'log_kind': 'off_plan',
          'logged_at': now.toUtc().toIso8601String(),
          'editable_until': '2026-10-21T10:36:02+00:00',
        };

    Map<String, dynamic> page(List<Map<String, dynamic>> logs,
            {int current = 1, int last = 1}) =>
        {
          'data': logs,
          'meta': {'current_page': current, 'last_page': last},
        };

    test('the day and the days around it are read, every page', () async {
      api.pages.addAll([
        page([serverLog(1)], last: 2),
        page([serverLog(2)], current: 2, last: 2),
      ]);

      final result = await repository.syncDay(now);

      expect(result.isSuccess, isTrue);
      expect(api.queries, [
        {'from': '2026-10-13', 'to': '2026-10-15', 'page': '1'},
        {'from': '2026-10-13', 'to': '2026-10-15', 'page': '2'},
      ]);
      expect((await entries()).map((e) => e.id), ['server-1', 'server-2']);
      expect((await entries()).first.name, 'أرز');
    });

    test('offline, the entries stay as they are', () async {
      await repository.logFood(_rice, grams: 250);
      api.pages.add(_offline);

      final result = await repository.syncDay(now);

      expect(result.failureOrNull, isA<NetworkFailure>());
      expect(await entries(), hasLength(1));
    });

    test('a log deleted on another device leaves after a read', () async {
      await repository.logFood(_rice, grams: 250);
      api.pages.add(page(const []));

      await repository.syncDay(now);

      expect(await entries(), isEmpty);
    });

    test('new grams are sent and the server\'s calories kept', () async {
      final entry = (await repository.logFood(_rice, grams: 250)).valueOrNull!;
      api.patchAnswers.add(serverLog(101, grams: 180, calories: 234));

      final result = await repository.updateGrams(entry.id, 180);

      expect(api.patches.single.path, 'me/meal-logs/101');
      expect(api.patches.single.body, {'quantity_grams': 180});
      expect(result.valueOrNull?.grams, 180);
      expect((await entries()).single.calories, 234);
    });

    test('a log the server no longer has leaves when it is changed', () async {
      final entry = (await repository.logFood(_rice, grams: 250)).valueOrNull!;
      api.patchAnswers.add(const NotFoundException('gone'));

      final result = await repository.updateGrams(entry.id, 180);

      expect(result.failureOrNull, isA<NotFoundFailure>());
      expect(await entries(), isEmpty);
    });

    test('a plan meal holds several logs, so it has no grams to change',
        () async {
      final entry = (await repository.logPlanned(sampleLunch())).valueOrNull!;
      final kept = (await entries()).single;

      expect(kept.id, entry.id);
      expect(kept.canEditGramsAt(now), isFalse);
    });
  });
}
