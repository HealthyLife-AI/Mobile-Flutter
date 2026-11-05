import '../../core/errors/result.dart';
import '../entities/appointment_entities.dart';

/// The patient's appointments (API guide 12.4). Booking, changing and
/// cancelling are not here yet (12.1 to 12.3).
abstract interface class AppointmentRepository {
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
