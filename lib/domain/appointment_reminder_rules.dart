import 'entities/appointment_entities.dart';

/// How long before an appointment a local reminder fires (API guide 10.6).
enum ReminderLead {
  oneDay(Duration(hours: 24)),
  oneHour(Duration(hours: 1)),
  fiveMinutes(Duration(minutes: 5));

  const ReminderLead(this.before);

  /// How long before the start the reminder fires.
  final Duration before;
}

/// One reminder the device should show. [key] is the same for the same
/// appointment and lead, so a reminder can be found again when the list
/// changes and its time has to move.
class PlannedReminder {
  const PlannedReminder({
    required this.appointmentId,
    required this.lead,
    required this.at,
  });

  final int appointmentId;
  final ReminderLead lead;

  /// When the reminder fires, as an instant.
  final DateTime at;

  String get key => 'appointment-$appointmentId-${lead.name}';
}

/// The reminders the device needs for [appointments] at [now] (API guide 10.6).
///
/// Only booked appointments get reminders. A reminder whose time is not after
/// [now] is left out, so an appointment that is an hour away gets its
/// five-minute reminder and no others. The result is ordered by time.
List<PlannedReminder> planAppointmentReminders(
  Iterable<Appointment> appointments,
  DateTime now,
) {
  final planned = <PlannedReminder>[];
  for (final appointment in appointments) {
    if (appointment.status != AppointmentStatus.booked) continue;
    for (final lead in ReminderLead.values) {
      final at = appointment.startsAt.subtract(lead.before);
      if (!at.isAfter(now)) continue;
      planned.add(PlannedReminder(
        appointmentId: appointment.id,
        lead: lead,
        at: at,
      ));
    }
  }
  planned.sort((a, b) => a.at.compareTo(b.at));
  return planned;
}
