import 'package:flutter/widgets.dart';

import '../../domain/appointment_reminder_rules.dart';
import '../../domain/weigh_in_reminder_rules.dart';
import '../../domain/repositories/appointment_reminder_scheduler.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import 'local_reminder_notifications.dart';

/// Shows the appointment reminders as local notifications (API guide 10.6).
///
/// Each reminder fires at its own instant, which is absolute, so the device's
/// time zone is not needed. [replaceAll] clears the app's scheduled
/// appointment reminders and then schedules the list again, so a reminder that
/// moved or was cancelled on the server is updated on the next read. The
/// weekly weigh-in reminder ([weighInNotificationId]) is left in place. The
/// text follows the language the patient chose, and Arabic when none is chosen.
class LocalAppointmentReminderScheduler
    implements AppointmentReminderScheduler {
  LocalAppointmentReminderScheduler(this._notifications, this._settings);

  final ReminderNotifications _notifications;
  final SettingsRepository _settings;

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) async {
    for (final id in await _notifications.scheduledIds()) {
      if (id != weighInNotificationId) await _notifications.cancel(id);
    }
    if (reminders.isEmpty) return;

    final copy = await _copy();
    for (final reminder in reminders) {
      await _notifications.schedule(
        id: reminderNotificationId(reminder.key),
        at: reminder.at,
        channelName: copy.appointmentReminderChannel,
        title: copy.appointmentReminderTitle,
        body: _bodyFor(copy, reminder.lead),
      );
    }
  }

  @override
  Future<void> cancelAll() => _notifications.cancelAll();

  Future<AppLocalizations> _copy() async {
    final locale =
        (await _settings.getLocale()).valueOrNull ?? const Locale('ar');
    return lookupAppLocalizations(locale);
  }
}

String _bodyFor(AppLocalizations copy, ReminderLead lead) => switch (lead) {
      ReminderLead.oneDay => copy.appointmentReminderDay,
      ReminderLead.oneHour => copy.appointmentReminderHour,
      ReminderLead.fiveMinutes => copy.appointmentReminderFiveMinutes,
    };

/// The notification number for a reminder [key]. The same key always gives the
/// same number, so a reminder that moves replaces the one already scheduled.
/// It is never [weighInNotificationId], which belongs to the weigh-in reminder.
int reminderNotificationId(String key) {
  var hash = 0;
  for (final unit in key.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return hash == weighInNotificationId ? hash + 1 : hash;
}
