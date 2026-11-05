import 'package:healthylife_ai/data/services/local_reminder_notifications.dart';

/// The device's notification plugin, kept in memory: what is scheduled, and
/// every call in order.
class RecordingNotifications implements ReminderNotifications {
  final List<String> calls = [];

  /// What was asked to show, in order.
  final List<
          ({int id, DateTime at, String channelId, String title, String body})>
      shown = [];

  /// What is still scheduled, by number.
  final Map<int, DateTime> scheduled = {};

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String channelName,
    required String title,
    required String body,
    String channelId = appointmentChannelId,
  }) async {
    calls.add('schedule');
    shown.add((id: id, at: at, channelId: channelId, title: title, body: body));
    scheduled[id] = at;
  }

  @override
  Future<List<int>> scheduledIds() async => scheduled.keys.toList();

  @override
  Future<void> cancel(int id) async {
    calls.add('cancel $id');
    scheduled.remove(id);
  }

  @override
  Future<void> cancelAll() async {
    calls.add('cancelAll');
    scheduled.clear();
  }
}
