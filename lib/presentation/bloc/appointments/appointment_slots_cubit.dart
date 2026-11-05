import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/result.dart';
import '../../../core/state/async_state.dart';
import '../../../domain/entities/appointment_entities.dart';
import '../../../domain/repositories/appointment_repository.dart';

/// The free times on the booking screen (API guide 12.1), and the booking or
/// the change it ends with (12.2, 12.3). Switching the kind drops the times of
/// the other kind; a result for a kind the patient has left is dropped.
class AppointmentSlotsCubit extends Cubit<AsyncState<AppointmentSlots>> {
  AppointmentSlotsCubit(this._repository) : super(const AsyncInitial());

  final AppointmentRepository _repository;
  AppointmentType? _type;

  /// The kind whose times are on screen.
  AppointmentType? get type => _type;

  Future<void> load(AppointmentType type) async {
    if (isClosed) return;
    final previous = type == _type ? state.dataOrNull : null;
    _type = type;
    emit(AsyncLoading<AppointmentSlots>(previous: previous));
    final result = await _repository.getSlots(type);
    if (isClosed || type != _type) return;
    result.when(
      success: (slots) => emit(AsyncSuccess(slots)),
      failure: (failure) => emit(AsyncError(failure, previous: previous)),
    );
  }

  Future<Result<Appointment>> book(AppointmentRequest request) =>
      _repository.book(request);

  Future<Result<Appointment>> reschedule(
          Appointment appointment, AppointmentSlot slot) =>
      _repository.reschedule(appointment, slot);
}
