import '../../core/errors/result.dart';
import '../entities/notification_preferences.dart';

/// The patient's notification settings on the server (API guide 10.5), with
/// the last known copy kept on the device.
abstract interface class NotificationPreferencesRepository {
  /// Reads the settings from the server. Offline, the last known copy.
  Future<Result<NotificationPreferences>> get();

  /// Saves [preferences] (`PUT /me/notification-preferences`) and returns
  /// what the server holds afterwards. Never queued: it needs a connection.
  Future<Result<NotificationPreferences>> update(
      NotificationPreferences preferences);

  /// The last known copy, or the server's defaults, without a request. Used
  /// to plan the device's own reminders.
  Future<NotificationPreferences> known();
}
