import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failure.dart';
import '../../../domain/entities/measurement_entities.dart';
import '../../../domain/measurement_schedule.dart';
import '../../../domain/repositories/measurement_repository.dart';

enum MeasurementsStatus { initial, loading, loaded, empty, error }

@immutable
class MeasurementsState {
  const MeasurementsState({
    this.status = MeasurementsStatus.initial,
    this.snapshot,
    this.failure,
    this.measurementDue = false,
  });

  final MeasurementsStatus status;
  final MeasurementSnapshot? snapshot;
  final Failure? failure;

  /// The patient has readings, and a week has passed since the latest one
  /// (the weekly weigh-in, API guide 10.6). Decided when the readings were
  /// read; [MeasurementsCubit.load] runs again on every return to the app.
  final bool measurementDue;

  MeasurementsState copyWith({
    MeasurementsStatus? status,
    MeasurementSnapshot? snapshot,
    Failure? failure,
    bool clearFailure = true,
    bool? measurementDue,
  }) =>
      MeasurementsState(
        status: status ?? this.status,
        snapshot: snapshot ?? this.snapshot,
        failure: failure ?? (clearFailure ? null : this.failure),
        measurementDue: measurementDue ?? this.measurementDue,
      );
}

class MeasurementsCubit extends Cubit<MeasurementsState> {
  MeasurementsCubit(this._repository, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        super(const MeasurementsState());

  final MeasurementRepository _repository;
  final DateTime Function() _clock;

  Future<void> load() async {
    if (state.status == MeasurementsStatus.initial) {
      emit(state.copyWith(status: MeasurementsStatus.loading));
    }
    final result = await _repository.getSnapshot();
    if (isClosed) return;
    result.when(
      success: (snapshot) => emit(state.copyWith(
        status: snapshot.isEmpty
            ? MeasurementsStatus.empty
            : MeasurementsStatus.loaded,
        snapshot: snapshot,
        measurementDue:
            !snapshot.isEmpty && isMeasurementDue(snapshot, now: _clock()),
      )),
      failure: (failure) => emit(MeasurementsState(
          status: MeasurementsStatus.error, failure: failure)),
    );
  }

  /// Drops what is on screen. Called when the session ends, so the next
  /// patient never sees the previous one's measurements.
  void reset() => emit(const MeasurementsState());
}
