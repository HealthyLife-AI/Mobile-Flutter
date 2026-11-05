import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/state/async_state.dart';
import 'package:healthylife_ai/core/storage/storage_service.dart';
import 'package:healthylife_ai/data/repositories/meal_plan_repository_impl.dart';
import 'package:healthylife_ai/domain/entities/meal_plan_entities.dart';
import 'package:healthylife_ai/presentation/bloc/meal_plan/meal_plan_cubit.dart';

import '../../helpers/sample_meal_plan.dart';

void main() {
  late FakeMealPlanSource source;
  late StreamController<void> changes;
  late MealPlanCubit cubit;

  setUp(() {
    source = FakeMealPlanSource(samplePlanJson());
    changes = StreamController<void>.broadcast();
    cubit = MealPlanCubit(
        MealPlanRepositoryImpl(MemoryStorageService(), source),
        changes: changes.stream);
  });

  tearDown(() async {
    await cubit.close();
    await changes.close();
  });

  test('loads the active plan', () async {
    await cubit.load();

    expect(cubit.state, isA<AsyncSuccess<MealPlan?>>());
    expect(cubit.state.dataOrNull?.id, 8);
  });

  test('no active plan is a success with no plan, not an error', () async {
    source.plan = null;

    await cubit.load();

    expect(cubit.state, isA<AsyncSuccess<MealPlan?>>());
    expect(cubit.state.dataOrNull, isNull);
  });

  test('a failed refresh keeps the plan already shown', () async {
    await cubit.load();
    source.error = const ServerException('down', statusCode: 500);

    await cubit.load();

    expect(cubit.state, isA<AsyncError<MealPlan?>>());
    expect(cubit.state.dataOrNull?.id, 8);
  });

  test('a plan push reads the plan again for a patient in the app', () async {
    await cubit.load();
    final updated = samplePlanJson()..['id'] = 9;
    source.plan = updated;

    changes.add(null);
    await pumpEventQueue();

    expect(source.calls, 2);
    expect(cubit.state.dataOrNull?.id, 9);
  });

  test('a plan push before the patient is in the app reads nothing', () async {
    changes.add(null);
    await pumpEventQueue();

    expect(source.calls, 0);
    expect(cubit.state, isA<AsyncInitial<MealPlan?>>());
  });

  test('a load that finishes after sign-out is dropped', () async {
    final pending = cubit.load();
    cubit.reset();
    await pending;

    expect(cubit.state, isA<AsyncInitial<MealPlan?>>());
  });
}
