/// What the appointments screen shows, from `GET /me/appointments` (API guide
/// 12.4). The server sends each time with the clinic's offset; the instant is
/// kept and the screen shows it in the device's own time.
library;

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

  /// Still on: booked and not started. Only then can it be changed or
  /// cancelled (12.3).
  bool isOpenAt(DateTime now) =>
      status == AppointmentStatus.booked && startsAt.isAfter(now);
}

/// The kinds a patient can book (12.1), in the order the screen offers them.
const List<AppointmentType> bookableAppointmentTypes = [
  AppointmentType.followUp,
  AppointmentType.resultsReview,
  AppointmentType.quickConsult,
];

/// The topics a booking can name, as the server names them (12.2).
const List<String> appointmentTopics = [
  'weight',
  'meals',
  'plan_change',
  'results',
  'medications',
  'other',
];

/// At most this many topics, and this long a note (12.2).
const int maxAppointmentTopics = 6;
const int maxAppointmentNoteLength = 300;

/// The free times for one kind of appointment, from 12 hours to 30 days ahead
/// (12.1). No days means the nutritionist has set no availability.
class AppointmentSlots {
  const AppointmentSlots({
    required this.type,
    required this.durationMinutes,
    required this.days,
    this.videoAvailable = false,
  });

  final AppointmentType type;
  final int durationMinutes;
  final List<SlotDay> days;

  /// False hides the video channel.
  final bool videoAvailable;

  bool get isEmpty => days.every((day) => day.times.isEmpty);
}

/// One day of free times, as the clinic counts days.
class SlotDay {
  const SlotDay({required this.date, required this.times});

  /// The clinic's calendar day, at local midnight.
  final DateTime date;
  final List<AppointmentSlot> times;
}

/// One free start time.
class AppointmentSlot {
  const AppointmentSlot({required this.startsAt, required this.value});

  /// The start, in the device's own time.
  final DateTime startsAt;

  /// The time exactly as the server sent it. Booking sends this string back
  /// (12.2), so the clinic's offset is kept.
  final String value;
}

/// What the patient asks for when booking (12.2).
class AppointmentRequest {
  const AppointmentRequest({
    required this.type,
    required this.slot,
    required this.channel,
    this.topics = const [],
    this.note,
  });

  final AppointmentType type;
  final AppointmentSlot slot;
  final AppointmentChannel channel;

  /// Server names from [appointmentTopics], at most [maxAppointmentTopics].
  final List<String> topics;
  final String? note;
}
