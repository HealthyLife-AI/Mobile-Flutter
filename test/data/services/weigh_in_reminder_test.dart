import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/result.dart';
import 'package:healthylife_ai/data/services/local_reminder_notifications.dart';
import 'package:healthylife_ai/data/services/weigh_in_reminder.dart';
import 'package:healthylife_ai/domain/entities/measurement_entities.dart';
import 'package:healthylife_ai/domain/entities/notification_preferences.dart';
import 'package:healthylife_ai/domain/repositories/notification_preferences_repository.dart';
import 'package:healthylife_ai/domain/repositories/settings_repository.dart';
import 'package:healthylife_ai/domain/weigh_in_reminder_rules.dart';
import 'package:healthylife_ai/l10n/l10n.dart';

import '../../helpers/recording_notifications.dart';

class _Settings implements SettingsRepository {
  @override
  Future<Result<ThemeMode>> getThemeMode() async =>
      const Success(ThemeMode.light);

  @override
  Future<Result<void>> setThemeMode(ThemeMode mode) async =>
      const Success(null);

  @override
  Future<Result<Locale?>> getLocale() async => const Success(null);

  @override
  Future<Result<void>> setLocale(Locale? locale) async => const Success(null);
}

class _Preferences implements NotificationPreferencesRepository {
  NotificationPreferences value = const NotificationPreferences();

  @override
  Future<NotificationPreferences> known() async => value;

  @override
  Future<Result<NotificationPreferences>> get() async => Success(value);

  @override
  Future<Result<NotificationPreferences>> update(
          NotificationPreferences preferences) async =>
      Success(value = preferences);
}

MeasurementSnapshot _latestOn(DateTime day) {
  final reading = MeasurementEntry(id: '1', recordedAt: day, weightKg: 80);
  return MeasurementSnapshot(
    currentWeight: 80,
    previousWeight: null,
    weightTrend: [WeightPoint(date: day, kg: 80)],
    circumference: const [],
    daysLoggedThisWeek: 0,
    daysLoggedThisMonth: 0,
    savedEntries: [reading],
  );
}

void main() {
  final now = DateTime(2026, 10, 15, 10);

  late RecordingNotifications notifications;
  late _Preferences preferences;
  late WeighInReminder reminder;

  setUp(() {
    notifications = RecordingNotifications();
    preferences = _Preferences();
    reminder = WeighInReminder(
      notifications: notifications,
      preferences: preferences,
      settings: _Settings(),
      clock: () => now,
    );
  });

  test('schedules the next weigh-in on its own channel, in Arabic', () async {
    await reminder.plan(_latestOn(DateTime(2026, 10, 12)));

    final shown = notifications.shown.single;
    final ar = lookupAppLocalizations(const Locale('ar'));
    expect(shown.id, weighInNotificationId);
    expect(shown.at, DateTime(2026, 10, 19, 9));
    expect(shown.channelId, weighInChannelId);
    expect(shown.title, ar.weighInReminderTitle);
  });

  test('a newer reading moves the reminder', () async {
    await reminder.plan(_latestOn(DateTime(2026, 10, 12)));
    await reminder.plan(_latestOn(DateTime(2026, 10, 15)));

    expect(notifications.scheduled,
        {weighInNotificationId: DateTime(2026, 10, 22, 9)});
  });

  test('measurement notifications off removes it', () async {
    await reminder.plan(_latestOn(DateTime(2026, 10, 12)));
    preferences.value = const NotificationPreferences(measurements: false);

    await reminder.plan(_latestOn(DateTime(2026, 10, 12)));

    expect(notifications.scheduled, isEmpty);
  });
}
