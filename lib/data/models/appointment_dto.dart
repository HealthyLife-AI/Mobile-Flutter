import '../../domain/entities/appointment_entities.dart';

/// Reads one item of `GET /me/appointments` (API guide 12.4). The reading is
/// lenient: a missing optional field is left out, and an item without an id or
/// a start time is skipped, because it cannot be shown. A value this version
/// does not know becomes `unknown`, so a new kind, channel or status does not
/// hide the appointment.
class AppointmentDto {
  const AppointmentDto._();

  static Appointment? fromJson(Map<String, dynamic> json) {
    final id = _int(json['id']);
    final startsAt = _time(json['starts_at']);
    if (id == null || startsAt == null) return null;
    return Appointment(
      id: id,
      type: _type(_text(json['type'])),
      channel: _channel(_text(json['channel'])),
      startsAt: startsAt,
      endsAt: _time(json['ends_at']),
      status: _status(_text(json['status'])),
      topics: _topics(json['topics']),
      note: _text(json['note']),
      cancelledBy: _cancelledBy(_text(json['cancelled_by'])),
      cancelReason: _text(json['cancel_reason']),
      meetingLink: _text(json['meeting_link']),
    );
  }

  static AppointmentType _type(String? value) => switch (value) {
        'follow_up' => AppointmentType.followUp,
        'results_review' => AppointmentType.resultsReview,
        'quick_consult' => AppointmentType.quickConsult,
        _ => AppointmentType.unknown,
      };

  static AppointmentChannel _channel(String? value) => switch (value) {
        'whatsapp' => AppointmentChannel.whatsapp,
        'phone' => AppointmentChannel.phone,
        'video' => AppointmentChannel.video,
        _ => AppointmentChannel.unknown,
      };

  static AppointmentStatus _status(String? value) => switch (value) {
        'booked' => AppointmentStatus.booked,
        'cancelled' => AppointmentStatus.cancelled,
        'completed' => AppointmentStatus.completed,
        'no_show' => AppointmentStatus.noShow,
        _ => AppointmentStatus.unknown,
      };

  /// Null when the appointment was not cancelled.
  static CancelledBy? _cancelledBy(String? value) {
    if (value == null) return null;
    return switch (value) {
      'patient' => CancelledBy.patient,
      'nutritionist' => CancelledBy.nutritionist,
      'system' => CancelledBy.system,
      _ => CancelledBy.unknown,
    };
  }

  static List<String> _topics(Object? raw) {
    if (raw is! List) return const [];
    return [
      for (final item in raw)
        if (item is String && item.trim().isNotEmpty) item.trim(),
    ];
  }

  static int? _int(Object? value) => value is int ? value : null;

  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// The instant, in the device's own time. Null when it cannot be read.
  static DateTime? _time(Object? value) {
    if (value is! String) return null;
    return DateTime.tryParse(value)?.toLocal();
  }
}
