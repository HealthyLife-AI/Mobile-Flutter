import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/result.dart';
import 'package:healthylife_ai/data/services/local_appointment_reminder_scheduler.dart';
import 'package:healthylife_ai/domain/appointment_reminder_rules.dart';
import 'package:healthylife_ai/domain/repositories/settings_repository.dart';
import 'package:healthylife_ai/domain/weigh_in_reminder_rules.dart';
import 'package:healthylife_ai/l10n/l10n.dart';

import '../../helpers/recording_notifications.dart';

/// Answers the language it was given, or no language when [locale] is null.
class _FixedSettings implements SettingsRepository {
  _FixedSettings(this.locale);

  final Locale? locale;

  @override
  Future<Result<ThemeMode>> getThemeMode() async =>
      const Success(ThemeMode.system);

  @override
  Future<Result<void>> setThemeMode(ThemeMode mode) async =>
      const Success(null);

  @override
  Future<Result<Locale?>> getLocale() async => Success(locale);

  @override
  Future<Result<void>> setLocale(Locale? locale) async => const Success(null);
}

typedef _RecordingNotifications = RecordingNotifications;

void main() {
  final start = DateTime.utc(2026, 10, 15, 7);

  PlannedReminder reminder(int appointmentId, ReminderLead lead, DateTime at) =>
      PlannedReminder(appointmentId: appointmentId, lead: lead, at: at);

  group('LocalAppointmentReminderScheduler (API guide 10.6)', () {
    test('clears the old reminders, then schedules each one at its instant',
        () async {
      final notifications = _RecordingNotifications();
      final scheduler = LocalAppointmentReminderScheduler(
        notifications,
        _FixedSettings(const Locale('en')),
      );

      await scheduler.replaceAll([
        reminder(7, ReminderLead.oneHour, start),
        reminder(7, ReminderLead.fiveMinutes,
            start.add(const Duration(minutes: 55))),
      ]);

      expect(notifications.calls, ['schedule', 'schedule']);
      expect(notifications.shown.map((s) => s.at), [
        start,
        start.add(const Duration(minutes: 55)),
      ]);
    });

    test('a new plan replaces the old appointment reminders only', () async {
      final notifications = _RecordingNotifications()
        ..scheduled[weighInNotificationId] = start
        ..scheduled[reminderNotificationId('old')] = start;
      final scheduler = LocalAppointmentReminderScheduler(
        notifications,
        _FixedSettings(null),
      );

      await scheduler.replaceAll([reminder(7, ReminderLead.oneHour, start)]);

      expect(notifications.scheduled.keys, contains(weighInNotificationId));
      expect(notifications.scheduled.keys,
          isNot(contains(reminderNotificationId('old'))));
      expect(notifications.scheduled, hasLength(2));
    });

    test('the text follows the language the patient chose', () async {
      final notifications = _RecordingNotifications();
      final scheduler = LocalAppointmentReminderScheduler(
        notifications,
        _FixedSettings(const Locale('en')),
      );
      final en = lookupAppLocalizations(const Locale('en'));

      await scheduler.replaceAll([
        reminder(7, ReminderLead.oneDay, start),
        reminder(7, ReminderLead.oneHour, start),
        reminder(7, ReminderLead.fiveMinutes, start),
      ]);

      expect(notifications.shown.map((s) => s.title),
          everyElement(en.appointmentReminderTitle));
      expect(notifications.shown.map((s) => s.body), [
        en.appointmentReminderDay,
        en.appointmentReminderHour,
        en.appointmentReminderFiveMinutes,
      ]);
    });

    test('Arabic is used when no language has been chosen', () async {
      final notifications = _RecordingNotifications();
      final scheduler = LocalAppointmentReminderScheduler(
        notifications,
        _FixedSettings(null),
      );
      final ar = lookupAppLocalizations(const Locale('ar'));

      await scheduler.replaceAll([reminder(7, ReminderLead.oneHour, start)]);

      expect(notifications.shown.single.title, ar.appointmentReminderTitle);
      expect(notifications.shown.single.body, ar.appointmentReminderHour);
    });

    test('an empty list clears the reminders and schedules nothing', () async {
      final notifications = _RecordingNotifications()
        ..scheduled[reminderNotificationId('old')] = start;
      final scheduler = LocalAppointmentReminderScheduler(
        notifications,
        _FixedSettings(null),
      );

      await scheduler.replaceAll([]);

      expect(notifications.scheduled, isEmpty);
      expect(notifications.shown, isEmpty);
    });

    test('cancelAll only clears the scheduled reminders', () async {
      final notifications = _RecordingNotifications();
      final scheduler = LocalAppointmentReminderScheduler(
        notifications,
        _FixedSettings(null),
      );

      await scheduler.cancelAll();

      expect(notifications.calls, ['cancelAll']);
    });
  });

  group('reminderNotificationId', () {
    test('the same key always gives the same number', () {
      expect(
        reminderNotificationId('appointment-7-oneHour'),
        reminderNotificationId('appointment-7-oneHour'),
      );
    });

    test('other appointments and other leads get other numbers', () {
      final ids = {
        reminderNotificationId('appointment-7-oneDay'),
        reminderNotificationId('appointment-7-oneHour'),
        reminderNotificationId('appointment-7-fiveMinutes'),
        reminderNotificationId('appointment-8-oneHour'),
      };

      expect(ids, hasLength(4));
    });

    test('the number fits a 32-bit Android notification id', () {
      final id = reminderNotificationId('appointment-2147483647-fiveMinutes');

      expect(id, greaterThanOrEqualTo(0));
      expect(id, lessThanOrEqualTo(0x7fffffff));
    });
  });
}
