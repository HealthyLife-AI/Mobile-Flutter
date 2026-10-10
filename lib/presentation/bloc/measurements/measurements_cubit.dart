import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failure.dart';
import '../../../core/errors/result.dart';
import '../../../domain/entities/measurement_entities.dart';
import '../../../domain/repositories/measurement_repository.dart';
import '../../../domain/usecases/save_measurement_use_case.dart';

enum MeasurementsStatus { initial, loading, loaded, empty, error }

@immutable
class MeasurementsState {
  const MeasurementsState({
    this.status = MeasurementsStatus.initial,
    this.snapshot,
    this.failure,
    this.saving = false,
    this.lastSaved,
  });

  final MeasurementsStatus status;
  final MeasurementSnapshot? snapshot;
  final Failure? failure;

  /// True while a save request is in flight (submit guard).
  final bool saving;

  /// Set after a successful save so the entry screen can react (navigate,
  /// show success) exactly once.
  final MeasurementEntry? lastSaved;

  MeasurementsState copyWith({
    MeasurementsStatus? status,
    MeasurementSnapshot? snapshot,
    Failure? failure,
    bool saving = false,
    MeasurementEntry? lastSaved,
    bool clearFailure = true,
    bool clearLastSaved = true,
  }) =>
      MeasurementsState(
        status: status ?? this.status,
        snapshot: snapshot ?? this.snapshot,
        failure: failure ?? (clearFailure ? null : this.failure),
        saving: saving,
        lastSaved: clearLastSaved ? null : (lastSaved ?? this.lastSaved),
      );
}

class MeasurementsCubit extends Cubit<MeasurementsState> {
  MeasurementsCubit(this._repository, this._saveMeasurement) : super(const MeasurementsState());

  final MeasurementRepository _repository;
  final SaveMeasurementUseCase _saveMeasurement;

  Future<void> load() async {
    if (state.status == MeasurementsStatus.initial) {
      emit(state.copyWith(status: MeasurementsStatus.loading));
    }
    final result = await _repository.getSnapshot();
    if (isClosed) return;
    result.when(
      success: (snapshot) => emit(state.copyWith(
        status: snapshot.isEmpty ? MeasurementsStatus.empty : MeasurementsStatus.loaded,
        snapshot: snapshot,
      )),
      failure: (failure) => emit(MeasurementsState(status: MeasurementsStatus.error, failure: failure)),
    );
  }

  Future<Result<MeasurementSnapshot>> save(MeasurementEntry entry) async {
    if (state.saving) return Failed(state.failure ?? const UnexpectedFailure());
    emit(state.copyWith(saving: true, status: state.status, snapshot: state.snapshot));
    final result = await _saveMeasurement(entry);
    if (isClosed) return result;
    result.when(
      success: (snapshot) => emit(MeasurementsState(
        status: MeasurementsStatus.loaded,
        snapshot: snapshot,
        lastSaved: entry,
      )),
      failure: (failure) => emit(state.copyWith(saving: false, failure: failure, status: state.status, snapshot: state.snapshot)),
    );
    return result;
  }
}
