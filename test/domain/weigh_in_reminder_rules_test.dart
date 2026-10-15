import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/domain/entities/measurement_entities.dart';
import 'package:healthylife_ai/domain/entities/notification_preferences.dart';
import 'package:healthylife_ai/domain/weigh_in_reminder_rules.dart';

MeasurementSnapshot _latestOn(DateTime? day) {
  final readings = [
    if (day != null) MeasurementEntry(id: '1', recordedAt: day, weightKg: 80),
  ];
  return MeasurementSnapshot(
    currentWeight: readings.isEmpty ? null : 80,
    previousWeight: null,
    weightTrend: [
      for (final r in readings) WeightPoint(date: r.recordedAt, kg: 80)
    ],
    circumference: const [],
    daysLoggedThisWeek: 0,
    daysLoggedThisMonth: 0,
    savedEntries: readings,
  );
}

void main() {
  // Thursday 15 October, 10:00.
  final now = DateTime(2026, 10, 15, 10);
  const prefs = NotificationPreferences();

  group('weighInReminderAt (API guide 10.6)', () {
    test('a week after the latest reading, in the morning', () {
      expect(
        weighInReminderAt(
            snapshot: _latestOn(DateTime(2026, 10, 12)),
            preferences: prefs,
            now: now),
        DateTime(2026, 10, 19, 9),
      );
    });

    test('measurement notifications off: no reminder', () {
      expect(
        weighInReminderAt(
            snapshot: _latestOn(DateTime(2026, 10, 12)),
            preferences: prefs.copyWith(measurements: false),
            now: now),
        isNull,
      );
    });

    test('no reading yet: no reminder (the wizard asks for the first)', () {
      expect(
          weighInReminderAt(
              snapshot: _latestOn(null), preferences: prefs, now: now),
          isNull);
    });

    test('a morning inside the quiet hours moves to their end', () {
      final late = prefs.copyWith(
          quietStartMinute: 22 * 60, quietEndMinute: 10 * 60 + 30);
      expect(
        weighInReminderAt(
            snapshot: _latestOn(DateTime(2026, 10, 12)),
            preferences: late,
            now: now),
        DateTime(2026, 10, 19, 10, 30),
      );
    });

    test('quiet hours switched off keep the morning', () {
      final late = prefs.copyWith(
          quietHoursEnabled: false, quietEndMinute: 10 * 60 + 30);
      expect(
        weighInReminderAt(
            snapshot: _latestOn(DateTime(2026, 10, 12)),
            preferences: late,
            now: now),
        DateTime(2026, 10, 19, 9),
      );
    });

    test('already due and this morning has passed: tomorrow morning', () {
      expect(
        weighInReminderAt(
            snapshot: _latestOn(DateTime(2026, 10, 1)),
            preferences: prefs,
            now: now),
        DateTime(2026, 10, 16, 9),
      );
    });

    test('already due before this morning\'s time: this morning', () {
      expect(
        weighInReminderAt(
            snapshot: _latestOn(DateTime(2026, 10, 1)),
            preferences: prefs,
            now: DateTime(2026, 10, 15, 7)),
        DateTime(2026, 10, 15, 9),
      );
    });
  });

  group('NotificationPreferences.isQuietAt', () {
    test('a range across midnight', () {
      const p = NotificationPreferences(); // 22:00–07:00
      expect(p.isQuietAt(23 * 60), isTrue);
      expect(p.isQuietAt(3 * 60), isTrue);
      expect(p.isQuietAt(7 * 60), isFalse);
      expect(p.isQuietAt(12 * 60), isFalse);
    });

    test('a range within one day', () {
      const p = NotificationPreferences(
          quietStartMinute: 13 * 60, quietEndMinute: 15 * 60);
      expect(p.isQuietAt(14 * 60), isTrue);
      expect(p.isQuietAt(16 * 60), isFalse);
    });
  });
}
