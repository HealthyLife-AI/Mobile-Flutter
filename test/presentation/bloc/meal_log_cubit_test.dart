import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/result.dart';
import 'package:healthylife_ai/domain/entities/meal_entities.dart';
import 'package:healthylife_ai/domain/entities/meal_plan_entities.dart';
import 'package:healthylife_ai/domain/repositories/meal_log_repository.dart';
import 'package:healthylife_ai/domain/usecases/log_meal_use_case.dart';
import 'package:healthylife_ai/presentation/bloc/meal_log/meal_log_cubit.dart';

/// Answers the log with [entries]. A read waits on [gate] when one is set.
class _FakeMealLog implements MealLogRepository {
  _FakeMealLog(this.entries);

  final List<MealLogEntry> entries;
  Completer<void>? gate;

  @override
  Future<Result<List<MealLogEntry>>> getEntries() async {
    await gate?.future;
    return Success(List.unmodifiable(entries));
  }

  @override
  Future<Result<MealLogEntry>> logPlanned(Meal meal, {List<PlanItem>? eaten}) =>
      throw UnimplementedError();

  @override
  Future<Result<MealLogEntry>> logFood(SearchableFood food,
          {required int grams}) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> clear() => throw UnimplementedError();
}

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

MealLogEntry _planned(DateTime at) => MealLogEntry(
      id: 'planned-${at.microsecondsSinceEpoch}',
      name: _lunch.name,
      calories: _lunch.calories,
      grams: 150,
      loggedAt: at,
      isOffPlan: false,
      plannedMeal: _lunch,
    );

void main() {
  test('reset returns the log to its first state', () async {
    final repo = _FakeMealLog([_planned(DateTime.now())]);
    final cubit = MealLogCubit(repo, LogMealUseCase(repo));
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.status, MealLogStatus.loaded);

    cubit.reset();

    expect(cubit.state.status, MealLogStatus.initial);
    expect(cubit.state.entries, isEmpty);
  });

  test('a read that finishes after a reset does not show what it read',
      () async {
    final repo = _FakeMealLog([_planned(DateTime.now())])
      ..gate = Completer<void>();
    final cubit = MealLogCubit(repo, LogMealUseCase(repo));
    addTearDown(cubit.close);

    final loading = cubit.load();
    cubit.reset(); // the patient has signed out
    repo.gate!.complete();
    await loading;

    expect(cubit.state.entries, isEmpty);
    expect(cubit.state.status, MealLogStatus.initial);
  });

  test('a planned meal counts as logged only for today', () async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final repo = _FakeMealLog([_planned(yesterday)]);
    final cubit = MealLogCubit(repo, LogMealUseCase(repo));
    addTearDown(cubit.close);
    await cubit.load();

    expect(cubit.state.isPlannedLogged(_lunch.id), isFalse);

    repo.entries.add(_planned(DateTime.now()));
    await cubit.load();

    expect(cubit.state.isPlannedLogged(_lunch.id), isTrue);
  });
}
