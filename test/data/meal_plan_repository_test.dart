import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/navigation/push_destination.dart';
import 'package:healthylife_ai/core/storage/storage_service.dart';
import 'package:healthylife_ai/data/models/meal_plan_dto.dart';
import 'package:healthylife_ai/data/repositories/meal_plan_repository_impl.dart';
import 'package:healthylife_ai/domain/entities/meal_plan_entities.dart';

import '../helpers/sample_meal_plan.dart';

const NetworkException _offline =
    NetworkException('no connection', kind: NetworkFailureKind.offline);

void main() {
  // A Wednesday, so day_index 2 (Monday is 0).
  final wednesday = DateTime(2026, 10, 14, 9);

  group('reading GET /me/meal-plan (API guide 5.1)', () {
    test('keeps ids, meal types, items, grams, macros and alternatives', () {
      final plan = samplePlan(today: wednesday);

      expect(plan.id, 8);
      expect(plan.startDate, DateTime(2026, 9, 30));
      expect(plan.meals.map((m) => m.type), [
        PlanMealType.breakfast,
        PlanMealType.lunch,
        PlanMealType.dinner,
        PlanMealType.snack,
      ]);
      final lunch = plan.meals[1];
      expect(lunch.id, 22);
      expect(lunch.dayIndex, isNull, reason: 'null = every day');
      expect(lunch.macros.calories, 422);
      expect(lunch.items.map((i) => i.id), [60, 62, 64]);
      final chicken = lunch.items.first;
      expect(chicken.food.id, 6);
      expect(chicken.food.name, 'صدر دجاج مشوي', reason: 'name_ar first');
      expect(chicken.quantityGrams, 150);
      expect(chicken.alternatives.single.id, 61);
      expect(chicken.alternatives.single.macros.calories, 192);
      expect(plan.meals.last.dayIndex, 2);
    });

    test('an item without a usable food is skipped; an empty meal is dropped',
        () {
      final json = samplePlanJson(today: wednesday);
      final meals = json['meals'] as List;
      (meals[0] as Map)['items'] = [
        {'id': 1, 'food': null, 'quantity_grams': 10},
      ];

      final plan = MealPlanDto.fromJson(json)!;

      expect(plan.meals.map((m) => m.id), [22, 23, 24]);
    });

    test('an unknown meal name is kept as "other", not dropped', () {
      final json = samplePlanJson(today: wednesday);
      ((json['meals'] as List)[2] as Map)['name'] = 'brunch';

      expect(MealPlanDto.fromJson(json)!.meals[2].type, PlanMealType.other);
    });

    test('a plan without an id is unreadable', () {
      final json = samplePlanJson(today: wednesday)..remove('id');

      expect(MealPlanDto.fromJson(json), isNull);
    });
  });

  group('a day of the plan', () {
    final plan = samplePlan(today: wednesday);

    test('is the daily meals plus that weekday\'s meals', () {
      expect(plan.mealsOn(wednesday).map((m) => m.id), [21, 22, 23, 24]);
      final thursday = wednesday.add(const Duration(days: 1));
      expect(plan.mealsOn(thursday).map((m) => m.id), [21, 22, 23]);
    });

    test('totals use summary_by_day, or the meals when the day has none', () {
      expect(plan.totalOn(wednesday).calories, 993);
      final thursday = wednesday.add(const Duration(days: 1));
      expect(plan.totalOn(thursday).calories, 330 + 422 + 146);
    });
  });

  group('MealPlanRepositoryImpl', () {
    late MemoryStorageService storage;
    late FakeMealPlanSource source;
    late MealPlanRepositoryImpl repository;

    setUp(() {
      storage = MemoryStorageService();
      source = FakeMealPlanSource(samplePlanJson(today: wednesday));
      repository = MealPlanRepositoryImpl(storage, source);
    });

    test('returns the active plan and keeps a copy for offline use', () async {
      final plan = (await repository.getActivePlan()).valueOrNull;

      expect(plan?.id, 8);
      expect(await storage.readMap(StorageKeys.mealPlan), isNotNull);
    });

    test('204 (no active plan) is null, not a failure, and drops the copy',
        () async {
      await repository.getActivePlan();
      source.plan = null;

      final result = await repository.getActivePlan();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isNull);
      expect(await storage.readMap(StorageKeys.mealPlan), isNull);
    });

    test('offline, the last plan read is shown', () async {
      await repository.getActivePlan();
      source.error = _offline;

      expect((await repository.getActivePlan()).valueOrNull?.id, 8);
    });

    test('offline with no copy, the read fails', () async {
      source.error = _offline;

      expect((await repository.getActivePlan()).isSuccess, isFalse);
    });

    test('a server error is a failure even with a copy', () async {
      await repository.getActivePlan();
      source.error = const ServerException('down', statusCode: 500);

      expect((await repository.getActivePlan()).isSuccess, isFalse);
    });

    test('the copy is forgotten at sign-out', () async {
      await repository.getActivePlan();

      await repository.forgetPatientData();

      expect(await storage.readMap(StorageKeys.mealPlan), isNull);
    });
  });

  test('plan pushes are recognised; others are not (API guide 10.3)', () {
    expect(isPlanChangePush({'type': 'plan_activated'}), isTrue);
    expect(isPlanChangePush({'type': 'plan_updated', 'plan_id': '8'}), isTrue);
    expect(isPlanChangePush({'type': 'review_new'}), isFalse);
    expect(isPlanChangePush(null), isFalse);
  });
}
