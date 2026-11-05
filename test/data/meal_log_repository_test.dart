import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/network/api_client.dart';
import 'package:healthylife_ai/core/storage/storage_service.dart';
import 'package:healthylife_ai/core/sync/offline_queue.dart';
import 'package:healthylife_ai/data/repositories/meal_log_repository_impl.dart';
import 'package:healthylife_ai/domain/entities/meal_entities.dart';

import '../helpers/sample_meal_plan.dart';

/// Records each write. Each write takes the next answer: null saves it, an
/// [AppException] is thrown. When no answers are left, writes are saved.
class _ScriptedApi implements ApiClient {
  final List<String> paths = [];
  final List<Map<String, dynamic>> bodies = [];
  final List<Object?> answers = [];

  @override
  Future<dynamic> post(String path, {Object? body, bool auth = true}) async {
    paths.add(path);
    bodies.add(Map<String, dynamic>.from(body as Map));
    final next = answers.isEmpty ? null : answers.removeAt(0);
    if (next is AppException) throw next;
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
    );
    repository = MealLogRepositoryImpl(
      storage,
      queue,
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
}
