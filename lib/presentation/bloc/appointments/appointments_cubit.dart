import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/state/async_state.dart';
import '../../../domain/entities/appointment_entities.dart';
import '../../../domain/repositories/appointment_repository.dart';

/// Loads the upcoming or the past appointments (API guide 12.4). One list is
/// on screen at a time: switching tabs drops the list of the other tab, so it
/// is never shown under the wrong heading. A refresh that fails keeps the list
/// already on screen. A result for a tab the patient has left is dropped.
class AppointmentsCubit extends Cubit<AsyncState<List<Appointment>>> {
  AppointmentsCubit(this._repository) : super(const AsyncInitial());

  final AppointmentRepository _repository;

  AppointmentScope _scope = AppointmentScope.upcoming;

  /// The list the screen is showing.
  AppointmentScope get scope => _scope;

  /// Loads the list for [scope], or for the current one when none is given.
  Future<void> load({AppointmentScope? scope}) async {
    if (isClosed) return;
    final switching = scope != null && scope != _scope;
    if (scope != null) _scope = scope;
    final requested = _scope;
    final previous = switching ? null : state.dataOrNull;
    emit(AsyncLoading<List<Appointment>>(previous: previous));

    final result = await _repository.getAppointments(scope: requested);
    if (isClosed || requested != _scope) return;
    result.when(
      success: (items) => emit(AsyncSuccess(items)),
      failure: (failure) => emit(AsyncError(failure, previous: previous)),
    );
  }
}
