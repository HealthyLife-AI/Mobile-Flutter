import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failure.dart';
import '../../../core/errors/result.dart';
import '../../../domain/entities/meal_entities.dart';
import '../../../domain/repositories/meal_log_repository.dart';
import '../../../domain/usecases/log_meal_use_case.dart';

enum MealLogStatus { initial, loading, loaded, empty, error }

@immutable
class MealLogState {
  const MealLogState({this.status = MealLogStatus.initial, this.entries = const [], this.failure, this.busy = false});

  final MealLogStatus status;
  final List<MealLogEntry> entries;
  final Failure? failure;

  /// True while a log write is in flight — screens disable their CTAs.
  final bool busy;

  int get totalCalories => entries.fold(0, (sum, e) => sum + e.calories);
  int get plannedCount => entries.where((e) => !e.isOffPlan).length;
  int get offPlanCount => entries.where((e) => e.isOffPlan).length;

  bool isPlannedLogged(String mealId) => entries.any((e) => e.plannedMeal?.id == mealId);

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

class MealLogCubit extends Cubit<MealLogState> {
  MealLogCubit(this._repository, this._logMeal) : super(const MealLogState());

  final MealLogRepository _repository;
  final LogMealUseCase _logMeal;

  Future<void> load() async {
    if (state.status == MealLogStatus.initial) {
      emit(state.copyWith(status: MealLogStatus.loading));
    }
    final result = await _repository.getEntries();
    if (isClosed) return;
    result.when(
      success: (entries) => emit(
        entries.isEmpty
            ? state.copyWith(status: MealLogStatus.empty, entries: entries)
            : state.copyWith(status: MealLogStatus.loaded, entries: entries),
      ),
      failure: (failure) => emit(MealLogState(status: MealLogStatus.error, failure: failure)),
    );
  }

  Future<Result<MealLogEntry>> logPlanned(Meal meal) async {
    emit(state.copyWith(busy: true));
    final result = await _logMeal.logPlanned(meal);
    await _refreshAfterWrite(result);
    return result;
  }

  Future<Result<MealLogEntry>> logFood(SearchableFood food, {required int grams}) async {
    emit(state.copyWith(busy: true));
    final result = await _logMeal.logFood(food, grams: grams);
    await _refreshAfterWrite(result);
    return result;
  }

  Future<void> _refreshAfterWrite(Result<MealLogEntry> result) async {
    if (isClosed) return;
    if (result case Failed<MealLogEntry>(:final failure)) {
      emit(state.copyWith(busy: false, failure: failure));
      return;
    }
    final entries = await _repository.getEntries();
    if (isClosed) return;
    emit(state.copyWith(
      status: MealLogStatus.loaded,
      entries: entries.valueOrNull ?? state.entries,
      busy: false,
    ));
  }
}
