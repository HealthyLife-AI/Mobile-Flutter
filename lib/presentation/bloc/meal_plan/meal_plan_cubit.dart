import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/state/async_state.dart';
import '../../../domain/entities/meal_plan_entities.dart';
import '../../../domain/repositories/meal_plan_repository.dart';

/// The plan the nutritionist set, for every screen that shows it (API guide
/// 5.1). `AsyncSuccess(null)` means no active plan yet: an empty state, not an
/// error.
///
/// Loaded when the patient enters the app and reset when they leave (2.5).
/// Read again when a plan push arrives ([changes], 10.3) and when the app
/// returns to the foreground (5.1). A refresh keeps the plan already on
/// screen while it loads, and when it fails.
class MealPlanCubit extends Cubit<AsyncState<MealPlan?>> {
  MealPlanCubit(this._repository, {Stream<void>? changes})
      : super(const AsyncInitial()) {
    _changes = changes?.listen((_) {
      // Only for a patient who is in the app; a reset plan stays reset.
      if (state is! AsyncInitial<MealPlan?>) unawaited(load());
    });
  }

  final MealPlanRepository _repository;
  StreamSubscription<void>? _changes;

  /// Bumped by [reset]. A load that finishes after a reset belongs to the
  /// patient who has left, so its result is dropped.
  int _generation = 0;

  Future<void> load() async {
    if (isClosed) return;
    final generation = _generation;
    final previous = state.dataOrNull;
    emit(AsyncLoading<MealPlan?>(previous: previous));
    final result = await _repository.getActivePlan();
    if (isClosed || generation != _generation) return;
    result.when(
      success: (plan) => emit(AsyncSuccess<MealPlan?>(plan)),
      failure: (failure) =>
          emit(AsyncError<MealPlan?>(failure, previous: previous)),
    );
  }

  /// Forgets the plan. Called when the patient leaves the app.
  void reset() {
    _generation++;
    if (isClosed) return;
    emit(const AsyncInitial());
  }

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }
}
