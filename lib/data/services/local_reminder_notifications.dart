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

/// The Android channel of the server's pushes. A push carries no channel id
/// (API guide 10.4), so AndroidManifest.xml names this one as FCM's default.
/// The two values must stay the same.
const String pushChannelId = 'healthylife_updates';

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
        // A flat, one-colour drawable (res/drawable/ic_stat_notification.xml);
        // the launcher icon would show as a white square.
        android: AndroidInitializationSettings('ic_stat_notification'),
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

  /// Creates the Android channel [id], or renames it to [name] when it is
  /// already there. Other platforms have no channels.
  Future<void> createChannel({required String id, required String name}) async {
    await _prepare();
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
            AndroidNotificationChannel(id, name, importance: Importance.high));
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

/// Reminders that go nowhere, for a graph that runs off the device (tests):
/// the notification plugin has no platform side there.
class SilentReminderNotifications implements ReminderNotifications {
  const SilentReminderNotifications();

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String channelName,
    required String title,
    required String body,
    String channelId = appointmentChannelId,
  }) async {}

  @override
  Future<List<int>> scheduledIds() async => const [];

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAll() async {}
}
