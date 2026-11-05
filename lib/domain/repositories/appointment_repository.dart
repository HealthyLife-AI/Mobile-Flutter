import '../../core/errors/result.dart';
import '../entities/appointment_entities.dart';

<<<<<<< HEAD
/// The patient's appointments (API guide 12): the lists, the free times, and
/// booking, changing and cancelling. Every write needs a connection, and
/// plans the device's reminders again once it succeeds (10.6).
///
/// The server's refusals come back as an `ApiFailure` with its `code`:
/// `appointment_exists`, `slot_unavailable`, `slot_taken`,
/// `video_unavailable`, `appointment_locked` (with `lock_hours` and
/// `nutritionist_whatsapp`) and `appointment_closed`.
abstract interface class AppointmentRepository {
  /// The free times for [type] (12.1).
  Future<Result<AppointmentSlots>> getSlots(AppointmentType type);

  /// Books one of the free times (12.2). One upcoming appointment is allowed
  /// at a time.
  Future<Result<Appointment>> book(AppointmentRequest request);

  /// Moves [appointment] to [slot], a fresh time of the same kind (12.3).
  Future<Result<Appointment>> reschedule(
      Appointment appointment, AppointmentSlot slot);

  /// Cancels [appointment] (12.3).
  Future<Result<Appointment>> cancel(Appointment appointment);

=======
/// The patient's appointments (API guide 12.4). Booking, changing and
/// cancelling are not here yet (12.1 to 12.3).
abstract interface class AppointmentRepository {
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
  /// The upcoming or the past appointments, in the order the screen shows them.
  /// A fresh upcoming list also plans the device's appointment reminders.
  Future<Result<List<Appointment>>> getAppointments({
    required AppointmentScope scope,
  });

  /// Reads the upcoming list again so the reminders follow the server, for
  /// example after an `appointment_*` push or when the app is ready (10.6).
  /// Never throws: a failure leaves the reminders as they are.
  Future<void> refreshReminders();
}
