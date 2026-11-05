import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/state/async_state.dart';
import '../../../domain/entities/nutritionist_entities.dart';
import '../../../domain/repositories/nutritionist_repository.dart';

/// Loads the patient's nutritionist (API guide 9.1). A refresh that fails
/// keeps the profile already on screen.
///
/// The app-wide instance names the nutritionist wherever the app mentions
/// them; it is loaded when the patient enters the app and reset when they
/// leave (2.5).
class NutritionistCubit extends Cubit<AsyncState<NutritionistProfile>> {
  NutritionistCubit(this._repository) : super(const AsyncInitial());

  final NutritionistRepository _repository;

  /// Bumped by [reset]: a load that finishes later is dropped.
  int _generation = 0;

  Future<void> load() async {
    if (isClosed) return;
    final generation = _generation;
    final previous = state.dataOrNull;
    emit(AsyncLoading<NutritionistProfile>(previous: previous));
    final result = await _repository.getProfile();
    if (isClosed || generation != _generation) return;
    result.when(
      success: (profile) => emit(AsyncSuccess(profile)),
      failure: (failure) => emit(AsyncError(failure, previous: previous)),
    );
  }

  /// Forgets the nutritionist. Called when the patient leaves the app.
  void reset() {
    _generation++;
    if (isClosed) return;
    emit(const AsyncInitial());
  }
}
