import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failure.dart';
import '../../../domain/entities/meal_entities.dart';
import '../../../domain/repositories/health_profile_repository.dart';
import '../../../domain/usecases/search_foods_use_case.dart';

enum FoodSearchStatus { loading, results, empty, error }

@immutable
class FoodSearchState {
  const FoodSearchState({
    this.status = FoodSearchStatus.loading,
    this.query = '',
    this.results = const [],
    this.failure,
    this.allergyGroups = const {},
    this.allergyCheckFailed = false,
  });

  final FoodSearchStatus status;
  final String query;
  final List<SearchableFood> results;
  final Failure? failure;

  /// The patient's approved allergy groups, without `other` (guide 5.3). Empty
  /// until the health profile has been read, or when it cannot be read.
  final Set<String> allergyGroups;

  /// True when the health profile could not be read, so no allergy badge shows
  /// and the screen says why.
  final bool allergyCheckFailed;

  FoodSearchState copyWith({
    FoodSearchStatus? status,
    String? query,
    List<SearchableFood>? results,
    Failure? failure,
    bool clearFailure = true,
    Set<String>? allergyGroups,
    bool? allergyCheckFailed,
  }) =>
      FoodSearchState(
        status: status ?? this.status,
        query: query ?? this.query,
        results: results ?? this.results,
        failure: failure ?? (clearFailure ? null : this.failure),
        allergyGroups: allergyGroups ?? this.allergyGroups,
        allergyCheckFailed: allergyCheckFailed ?? this.allergyCheckFailed,
      );
}

class FoodSearchCubit extends Cubit<FoodSearchState> {
  FoodSearchCubit(this._searchFoods,
      {this.debounce = const Duration(milliseconds: 250),
      HealthProfileRepository? healthProfile})
      : _healthProfile = healthProfile,
        super(const FoodSearchState());

  final SearchFoodsUseCase _searchFoods;
  final HealthProfileRepository? _healthProfile;
  final Duration debounce;
  Timer? _debounceTimer;
  int _requestId = 0;

  /// Debounced so we don't hit the server on every keystroke; results of stale
  /// requests are dropped via [_requestId].
  void queryChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () => _run(query));
  }

  Future<void> refresh() => _run(state.query);

  /// Reads the approved allergies for the allergy badge (guide 5.3). When the
  /// profile cannot be read, the badge stays off and the search still works.
  Future<void> loadAllergies() async {
    final profile = await _healthProfile?.getProfile();
    if (isClosed) return;
    final groups = profile?.valueOrNull?.allergies
            .map((allergy) => allergy.group)
            .whereType<String>()
            .where((group) => group != 'other')
            .toSet() ??
        const <String>{};
    emit(state.copyWith(
      allergyGroups: groups,
      allergyCheckFailed: profile?.failureOrNull != null,
    ));
  }

  Future<void> _run(String query) async {
    final id = ++_requestId;
    if (query.trim().isNotEmpty && query.trim().length >= 2) {
      emit(state.copyWith(status: FoodSearchStatus.loading, query: query));
    }
    final result = await _searchFoods(query);
    if (isClosed || id != _requestId) return; // stale response
    result.when(
      success: (foods) => emit(
        foods.isEmpty
            ? state.copyWith(
                status: FoodSearchStatus.empty, query: query, results: const [])
            : state.copyWith(
                status: FoodSearchStatus.results, query: query, results: foods),
      ),
      failure: (failure) => emit(state.copyWith(
        status: FoodSearchStatus.error,
        query: query,
        results: const [],
        failure: failure,
      )),
    );
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
