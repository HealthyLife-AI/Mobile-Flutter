import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/domain/appointment_reminder_rules.dart';
import 'package:healthylife_ai/domain/entities/appointment_entities.dart';

Appointment _appointment(
  int id,
  DateTime startsAt, {
  AppointmentStatus status = AppointmentStatus.booked,
}) =>
    Appointment(
      id: id,
      type: AppointmentType.followUp,
      channel: AppointmentChannel.whatsapp,
      startsAt: startsAt,
      endsAt: null,
      status: status,
    );

void main() {
  // Start: 10:00 in Hebron on 15 October, which is 07:00 UTC.
  final start = DateTime.utc(2026, 10, 15, 7);
  // Now: 06:00 UTC on 14 October, more than a day before the start.
  final now = DateTime.utc(2026, 10, 14, 6);

  group('planAppointmentReminders (API guide 10.6)', () {
    test('a booked appointment gets reminders 24 h, 1 h and 5 min before it',
        () {
      final planned = planAppointmentReminders([_appointment(7, start)], now);

      expect(planned.map((r) => r.lead), [
        ReminderLead.oneDay,
        ReminderLead.oneHour,
        ReminderLead.fiveMinutes,
      ]);
      expect(planned.map((r) => r.at), [
        DateTime.utc(2026, 10, 14, 7),
        DateTime.utc(2026, 10, 15, 6),
        DateTime.utc(2026, 10, 15, 6, 55),
      ]);
    });

    test('a reminder whose time has passed is left out', () {
      // An hour away: the one-day and one-hour reminders are no longer ahead.
      final planned = planAppointmentReminders(
        [_appointment(7, now.add(const Duration(hours: 1)))],
        now,
      );

      expect(planned.map((r) => r.lead), [ReminderLead.fiveMinutes]);
    });

    test('an appointment less than five minutes away has none left', () {
      final planned = planAppointmentReminders(
        [_appointment(7, now.add(const Duration(minutes: 4)))],
        now,
      );

      expect(planned, isEmpty);
    });

    test('only booked appointments get reminders', () {
      final planned = planAppointmentReminders([
        _appointment(1, start, status: AppointmentStatus.cancelled),
        _appointment(2, start, status: AppointmentStatus.completed),
        _appointment(3, start, status: AppointmentStatus.unknown),
      ], now);

      expect(planned, isEmpty);
    });

    test('the reminders of several appointments come out in time order', () {
      final planned = planAppointmentReminders([
        _appointment(2, start.add(const Duration(days: 2))),
        _appointment(1, start),
      ], now);

      final times = planned.map((r) => r.at).toList();
      expect(times, [...times]..sort());
    });

    test(
        'the key is the same for an appointment and lead, and differs otherwise',
        () {
      final planned = planAppointmentReminders([
        _appointment(7, start),
        _appointment(8, start),
      ], now);

      expect(planned.map((r) => r.key).toSet(), hasLength(6));
      expect(
        planAppointmentReminders([_appointment(7, start)], now)
            .map((r) => r.key),
        contains('appointment-7-oneHour'),
      );
    });

    test('a moved appointment keeps its keys and gets new times', () {
      final before = planAppointmentReminders([_appointment(7, start)], now);
      final after = planAppointmentReminders(
        [_appointment(7, start.add(const Duration(hours: 2)))],
        now,
      );

      expect(after.map((r) => r.key), before.map((r) => r.key));
      expect(after.map((r) => r.at), isNot(before.map((r) => r.at)));
    });
  });
}
