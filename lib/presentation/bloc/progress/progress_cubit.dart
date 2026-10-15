import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/state/async_state.dart';
import '../../../domain/entities/progress_entities.dart';
import '../../../domain/repositories/progress_repository.dart';

/// Loads the progress for the chart's window: the last [days] days, today
/// included. A refresh that fails keeps what is on screen. A result for a
/// window the patient has already left is dropped.
class ProgressCubit extends Cubit<AsyncState<ProgressSnapshot>> {
  ProgressCubit(this._repository, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        super(const AsyncInitial());

  final ProgressRepository _repository;
  final DateTime Function() _clock;

  int _days = 30;

  /// The window length the screen is showing, in days.
  int get days => _days;

  Future<void> load({int? days}) async {
    if (days != null) _days = days;
    if (isClosed) return;
    final requested = _days;
    final previous = state.dataOrNull;
    emit(AsyncLoading<ProgressSnapshot>(previous: previous));

    final now = _clock();
    final to = DateTime(now.year, now.month, now.day);
    // Calendar arithmetic, so a daylight-saving change does not move the date.
    final from = DateTime(to.year, to.month, to.day - (requested - 1));
    final result = await _repository.getProgress(from: from, to: to);
    if (isClosed || requested != _days) return;
    result.when(
      success: (snapshot) => emit(AsyncSuccess(snapshot)),
      failure: (failure) => emit(AsyncError(failure, previous: previous)),
    );
  }
}
