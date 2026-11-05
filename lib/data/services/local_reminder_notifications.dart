import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// The part of the notification plugin that the device's own reminders use
/// (appointments, the weekly weigh-in). It sits behind this interface so the
/// scheduling rules can be tested without a device.
abstract interface class ReminderNotifications {
  /// Shows one notification at [at], an absolute instant, with [id] as its
  /// number. A notification with the same [id] replaces the one already there.
  /// [channelId] groups it in the Android settings.
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String channelName,
    required String title,
    required String body,
    String channelId = appointmentChannelId,
  });

  /// The numbers of the notifications still to come.
  Future<List<int>> scheduledIds();

  /// Removes the notification numbered [id], if it is scheduled.
  Future<void> cancel(int id);

  /// Removes every notification the app has scheduled.
  Future<void> cancelAll();
}

/// The Android channel of the appointment reminders.
const String appointmentChannelId = 'appointment_reminders';

/// The Android channel of the weekly weigh-in reminder.
const String weighInChannelId = 'measurement_reminders';

/// The `flutter_local_notifications` plugin behind [ReminderNotifications].
///
/// It asks the OS for no permission. Initialisation turns off the iOS prompts,
/// so the permission request stays a separate decision (see the report). Until
/// it is made, iOS shows nothing, and Android 13 and later need the
/// notification permission before anything shows.
class FlutterReminderNotifications implements ReminderNotifications {
  FlutterReminderNotifications({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _prepared = false;

  Future<void> _prepare() async {
    if (_prepared) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _prepared = true;
  }

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String channelName,
    required String title,
    required String body,
    String channelId = appointmentChannelId,
  }) async {
    await _prepare();
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      // The instant is absolute, so UTC is enough to fire it at the right time.
      scheduledDate: tz.TZDateTime.from(at, tz.UTC),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      // Inexact, so no exact-alarm permission is needed. Android may deliver a
      // reminder a few minutes late, which matters for the 5-minute lead.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<List<int>> scheduledIds() async {
    await _prepare();
    return [
      for (final request in await _plugin.pendingNotificationRequests())
        request.id,
    ];
  }

  @override
  Future<void> cancel(int id) async {
    await _prepare();
    await _plugin.cancel(id: id);
  }

  @override
  Future<void> cancelAll() async {
    await _prepare();
    await _plugin.cancelAll();
  }
}
