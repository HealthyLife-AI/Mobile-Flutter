import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/result.dart';
import '../../../core/state/async_state.dart';
import '../../../domain/entities/patient_health_profile_entities.dart';
import '../../../domain/repositories/health_profile_repository.dart';

/// Loads the health record and sends the patient's change requests. A refresh
/// that fails keeps the profile already on screen. After a request is sent or
/// withdrawn, the profile is read again so the request list is current.
class HealthProfileCubit extends Cubit<AsyncState<PatientHealthProfile>> {
  HealthProfileCubit(this._repository) : super(const AsyncInitial());

  final HealthProfileRepository _repository;

  Future<void> load() async {
    if (isClosed) return;
    final previous = state.dataOrNull;
    emit(AsyncLoading<PatientHealthProfile>(previous: previous));
    final result = await _repository.getProfile();
    if (isClosed) return;
    result.when(
      success: (profile) => emit(AsyncSuccess(profile)),
      failure: (failure) => emit(AsyncError(failure, previous: previous)),
    );
  }

  Future<Result<void>> submit(ChangeRequestDraft draft) async {
    final result = await _repository.propose(draft);
    if (result.isSuccess) await load();
    return result;
  }

  Future<Result<void>> withdraw(int proposalId) async {
    final result = await _repository.withdraw(proposalId);
    if (result.isSuccess) await load();
    return result;
  }
}
