import 'entities/measurement_entities.dart';
import 'entities/notification_preferences.dart';
import 'measurement_schedule.dart';

/// The notification number of the weekly weigh-in reminder. Appointment
/// reminders get hashed numbers; this one is fixed, so it is the only one
/// those leave in place when they are planned again.
const int weighInNotificationId = 1;

/// The time of day the reminder asks for: the morning, after waking up, as
/// the measurement guide advises.
const int weighInMinuteOfDay = 9 * 60;

/// When the weekly weigh-in reminder should fire (API guide 10.6), or null
/// when none should: measurement notifications are off, or there is no
/// reading yet (the first-entry wizard asks for that one).
///
/// It fires on the due day (a week after the latest reading) in the morning,
/// moved to the end of the quiet hours if the morning falls inside them. A
/// reading that is already due is reminded the next morning that is still to
/// come; the app plans again whenever the readings are read.
DateTime? weighInReminderAt({
  required MeasurementSnapshot snapshot,
  required NotificationPreferences preferences,
  required DateTime now,
}) {
  if (!preferences.measurements) return null;
  final due = nextMeasurementDay(snapshot);
  if (due == null) return null;

  final minute = preferences.isQuietAt(weighInMinuteOfDay)
      ? preferences.quietEndMinute
      : weighInMinuteOfDay;
  DateTime at(DateTime day) =>
      DateTime(day.year, day.month, day.day, minute ~/ 60, minute % 60);

  var when = at(due);
  if (!when.isAfter(now)) {
    when = at(DateTime(now.year, now.month, now.day));
    if (!when.isAfter(now)) {
      when = at(DateTime(now.year, now.month, now.day + 1));
    }
  }
  return when;
}
