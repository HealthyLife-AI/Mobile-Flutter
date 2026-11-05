import '../appointment_reminder_rules.dart';

/// Shows the appointment reminders on this device (API guide 10.6). The app
/// owns these reminders, not the server, so nothing here is sent anywhere.
abstract interface class AppointmentReminderScheduler {
  /// Replaces every appointment reminder on the device with [reminders].
  Future<void> replaceAll(List<PlannedReminder> reminders);

  /// Removes every appointment reminder on the device. Called at sign-out.
  Future<void> cancelAll();
}
