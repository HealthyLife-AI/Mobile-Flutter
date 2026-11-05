import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failure.dart';
import '../../../core/errors/result.dart';
import '../../../core/time/date_only.dart';
import '../../../domain/entities/meal_entities.dart';
import '../../../domain/entities/meal_plan_entities.dart';
import '../../../domain/repositories/meal_log_repository.dart';
import '../../../domain/usecases/log_meal_use_case.dart';

enum MealLogStatus { initial, loading, loaded, empty, error }

@immutable
class MealLogState {
  const MealLogState(
      {this.status = MealLogStatus.initial,
      this.entries = const [],
      this.failure,
      this.busy = false});

  final MealLogStatus status;
  final List<MealLogEntry> entries;
  final Failure? failure;

  /// True while a log write is in flight — screens disable their CTAs.
  final bool busy;

  int get totalCalories => entries.fold(0, (sum, e) => sum + e.calories);
  int get plannedCount => entries.where((e) => !e.isOffPlan).length;
  int get offPlanCount => entries.where((e) => e.isOffPlan).length;

  /// Whether this plan meal is logged today. Entries from other days do not
  /// count, since a meal is logged once per day.
  bool isPlannedLogged(String mealId) => entries.any((e) =>
      e.plannedMeal?.id == mealId &&
      isSameLocalDay(e.loggedAt, DateTime.now()));

  MealLogState copyWith({
    MealLogStatus? status,
    List<MealLogEntry>? entries,
    Failure? failure,
    bool busy = false,
    bool clearFailure = true,
  }) =>
      MealLogState(
        status: status ?? this.status,
        entries: entries ?? this.entries,
        failure: failure ?? (clearFailure ? null : this.failure),
        busy: busy,
      );
}

/// The patient's meal log for the screens. It is loaded when the patient
/// enters the app and reset when they leave (2.5), so one patient's entries are
/// never shown to another.
class MealLogCubit extends Cubit<MealLogState> {
  MealLogCubit(this._repository, this._logMeal) : super(const MealLogState());

  final MealLogRepository _repository;
  final LogMealUseCase _logMeal;

  /// Bumped by [reset]. A load or write that finishes after a reset belongs to
  /// the patient who has left, so its result is dropped.
  int _generation = 0;

  Future<void> load() async {
    final generation = _generation;
    if (state.status == MealLogStatus.initial) {
      emit(state.copyWith(status: MealLogStatus.loading));
    }
    final result = await _repository.getEntries();
    if (_isStale(generation)) return;
    result.when(
      success: (entries) => emit(
        entries.isEmpty
            ? state.copyWith(status: MealLogStatus.empty, entries: entries)
            : state.copyWith(status: MealLogStatus.loaded, entries: entries),
      ),
      failure: (failure) =>
          emit(MealLogState(status: MealLogStatus.error, failure: failure)),
    );
  }

  /// Forgets what was loaded. Called when the patient leaves the app.
  void reset() {
    _generation++;
    if (isClosed) return;
    emit(const MealLogState());
  }

  /// [eaten]: what the patient chose per planned item (see
  /// [MealLogRepository.logPlanned]).
  Future<Result<MealLogEntry>> logPlanned(Meal meal,
      {List<PlanItem>? eaten}) async {
    final generation = _generation;
    emit(state.copyWith(busy: true));
    final result = await _logMeal.logPlanned(meal, eaten: eaten);
    await _refreshAfterWrite(result, generation);
    return result;
  }

  Future<Result<MealLogEntry>> logFood(SearchableFood food,
      {required int grams}) async {
    final generation = _generation;
    emit(state.copyWith(busy: true));
    final result = await _logMeal.logFood(food, grams: grams);
    await _refreshAfterWrite(result, generation);
    return result;
  }

  Future<void> _refreshAfterWrite(
      Result<MealLogEntry> result, int generation) async {
    if (_isStale(generation)) return;
    if (result case Failed<MealLogEntry>(:final failure)) {
      emit(state.copyWith(busy: false, failure: failure));
      return;
    }
    final entries = await _repository.getEntries();
    if (_isStale(generation)) return;
    emit(state.copyWith(
      status: MealLogStatus.loaded,
      entries: entries.valueOrNull ?? state.entries,
      busy: false,
    ));
  }

  bool _isStale(int generation) => isClosed || generation != _generation;
}
