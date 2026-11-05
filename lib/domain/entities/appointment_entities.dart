/// What the appointments screen shows, from `GET /me/appointments` (API guide
/// 12.4). The server sends each time with the clinic's offset; the instant is
/// kept and the screen shows it in the device's own time.

/// Which list is asked for. `upcoming` is booked and in the future, soonest
/// first. `past` is everything else, newest first.
enum AppointmentScope {
  upcoming('upcoming'),
  past('past');

  const AppointmentScope(this.apiValue);

  /// The value of `scope=` in the request.
  final String apiValue;
}

/// The kind of appointment (12.1 and 12.2). [unknown] keeps an appointment of a
/// kind this version does not know on screen, rather than hiding it.
enum AppointmentType { followUp, resultsReview, quickConsult, unknown }

/// How the appointment is held (12.2).
enum AppointmentChannel { whatsapp, phone, video, unknown }

/// The server's status (12.4). A past appointment can still be [booked] until
/// the nutritionist marks it completed or no-show.
enum AppointmentStatus { booked, cancelled, completed, noShow, unknown }

/// Who cancelled a cancelled appointment. [system] means the follow-up ended.
enum CancelledBy { patient, nutritionist, system, unknown }

class Appointment {
  const Appointment({
    required this.id,
    required this.type,
    required this.channel,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    this.topics = const [],
    this.note,
    this.cancelledBy,
    this.cancelReason,
    this.meetingLink,
  });

  final int id;
  final AppointmentType type;
  final AppointmentChannel channel;

  /// The start, in the device's own time.
  final DateTime startsAt;

  /// The end, in the device's own time. Null when the server did not send one.
  final DateTime? endsAt;

  final AppointmentStatus status;

  /// The patient's chosen topics, as the server names them.
  final List<String> topics;

  final String? note;
  final CancelledBy? cancelledBy;
  final String? cancelReason;

  /// Set for a video appointment only, and may be null even then.
  final String? meetingLink;
}
