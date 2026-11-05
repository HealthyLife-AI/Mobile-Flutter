import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/data/models/server_meal_log.dart';
import 'package:healthylife_ai/data/repositories/meal_log_sync.dart';
import 'package:healthylife_ai/domain/entities/meal_entities.dart';

import '../helpers/sample_meal_plan.dart';

final DateTime _day = DateTime(2026, 10, 14);
final DateTime _noon = DateTime(2026, 10, 14, 12, 30);

ServerMealLog _log(
  int id, {
  DateTime? at,
  int? mealItemId,
  String kind = 'off_plan',
  String food = 'تمر',
  int grams = 100,
  double calories = 280,
}) =>
    ServerMealLog(
      id: id,
      foodName: food,
      grams: grams,
      calories: calories,
      loggedAt: at ?? _noon,
      logKind: kind,
      mealItemId: mealItemId,
      editableUntil: DateTime(2026, 10, 21),
    );

MealLogEntry _entry(String id, List<SentMealLog> sent,
        {DateTime? at, Meal? meal}) =>
    MealLogEntry(
      id: id,
      name: meal?.name ?? 'تمر',
      calories: 280,
      grams: 100,
      loggedAt: at ?? _noon,
      isOffPlan: meal == null,
      plannedMeal: meal,
      sentLogs: sent,
    );

void main() {
  test('a log from another device joins its plan meal (6.2)', () {
    final lunch = sampleLunch();

    final result = reconcileMealLogs(
      entries: const [],
      day: _day,
      logs: [
        _log(1, mealItemId: 60, kind: 'planned', calories: 248, grams: 150),
        _log(2, mealItemId: 63, kind: 'alternative', calories: 129),
      ],
      waitingKeys: const {},
      planMeals: [lunch],
    );

    final entry = result.single;
    expect(entry.plannedMeal?.id, lunch.id);
    expect(entry.id, 'planned-${lunch.id}-2026-10-14');
    expect(entry.calories, 248 + 129);
    expect(entry.sentLogs.map((s) => s.serverId), [1, 2]);
  });

  test('a log matching no plan meal is an entry of its own', () {
    final result = reconcileMealLogs(
      entries: const [],
      day: _day,
      logs: [_log(7), _log(8, mealItemId: 999, kind: 'planned')],
      waitingKeys: const {},
    );

    expect(result.map((e) => e.id), ['server-7', 'server-8']);
    expect(result.first.isOffPlan, isTrue);
    expect(result.last.isOffPlan, isFalse);
    expect(result.first.canEditGramsAt(_day), isTrue);
  });

  test('a known log is not added again, and its window is kept up to date', () {
    final result = reconcileMealLogs(
      entries: [
        _entry('food-1', [const SentMealLog(key: 'k', serverId: 7)]),
      ],
      day: _day,
      logs: [_log(7)],
      waitingKeys: const {},
    );

    expect(result.single.id, 'food-1');
    expect(result.single.sentLogs.single.editableUntil, DateTime(2026, 10, 21));
  });

  test('an entry deleted on another device goes; one still waiting stays', () {
    final result = reconcileMealLogs(
      entries: [
        _entry('gone', [const SentMealLog(key: 'a', serverId: 7)]),
        _entry('waiting', [const SentMealLog(key: 'b')]),
        _entry('local only', const []),
      ],
      day: _day,
      logs: const [],
      waitingKeys: const {'b'},
    );

    expect(result.map((e) => e.id), ['waiting', 'local only']);
  });

  test('only the day asked for is checked for deletions', () {
    final yesterday = _entry(
        'yesterday', [const SentMealLog(key: 'a', serverId: 7)],
        at: DateTime(2026, 10, 13, 9));

    final result = reconcileMealLogs(
      entries: [yesterday],
      day: _day,
      logs: const [],
      waitingKeys: const {},
    );

    expect(result.single.id, 'yesterday');
  });

  test('an entry from before ids were kept takes the logs of its moment', () {
    final lunch = sampleLunch();
    final legacy = _entry('planned-22-2026-10-14', const [], meal: lunch);
    final sameMoment = _noon.add(const Duration(milliseconds: 600));

    final result = reconcileMealLogs(
      entries: [legacy],
      day: _day,
      logs: [
        _log(1, at: sameMoment, mealItemId: 60, kind: 'planned'),
        _log(2, at: sameMoment, mealItemId: 62, kind: 'planned'),
      ],
      waitingKeys: const {},
      planMeals: [lunch],
    );

    final entry = result.single;
    expect(entry.calories, 280, reason: 'nothing is counted twice');
    expect(entry.sentLogs.map((s) => s.serverId), [1, 2]);
  });

  test('a log whose answer was lost fills the slot of its moment', () {
    final result = reconcileMealLogs(
      entries: [
        _entry('food-1', [const SentMealLog(key: 'lost')]),
      ],
      day: _day,
      logs: [_log(9)],
      waitingKeys: const {},
    );

    final sent = result.single.sentLogs.single;
    expect(sent.key, 'lost');
    expect(sent.serverId, 9);
  });
}
