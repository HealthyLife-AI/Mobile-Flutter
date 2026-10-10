import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failure.dart';
import '../../../domain/entities/meal_entities.dart';
import '../../../domain/repositories/meal_plan_repository.dart';

enum MealPlanStatus { initial, loading, loaded, empty, error }

@immutable
class MealPlanState {
  const MealPlanState({this.status = MealPlanStatus.initial, this.meals = const [], this.failure});

  final MealPlanStatus status;
  final List<Meal> meals;
  final Failure? failure;

  bool get isLoading => status == MealPlanStatus.loading;

  MealPlanState copyWith({MealPlanStatus? status, List<Meal>? meals, Failure? failure, bool clearFailure = true}) =>
      MealPlanState(
        status: status ?? this.status,
        meals: meals ?? this.meals,
        failure: failure ?? (clearFailure ? null : this.failure),
      );
}

class MealPlanCubit extends Cubit<MealPlanState> {
  MealPlanCubit(this._repository) : super(const MealPlanState());

  final MealPlanRepository _repository;

  Future<void> load() async {
    if (state.status == MealPlanStatus.initial) {
      emit(state.copyWith(status: MealPlanStatus.loading));
    }
    final result = await _repository.getTodayMeals();
    if (isClosed) return;
    result.when(
      success: (meals) => emit(
        meals.isEmpty
            ? state.copyWith(status: MealPlanStatus.empty, meals: const [])
            : state.copyWith(status: MealPlanStatus.loaded, meals: meals),
      ),
      failure: (failure) => emit(MealPlanState(status: MealPlanStatus.error, failure: failure)),
    );
  }
}
