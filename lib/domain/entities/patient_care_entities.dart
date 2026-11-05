/// Phase 1 of the patient-app spec: the nutritionist's measurement schedule
/// and the patient's quick requests ("تواصل سريع").
///
/// Pure Dart: no Flutter imports, no wire format.
library;

/// `GET /me/measurement-schedule`: when the nutritionist wants the next
/// reading. The server moves [nextDueOn] after every saved reading.
class MeasurementSchedule {
  const MeasurementSchedule(
      {required this.intervalDays, required this.nextDueOn});

  final int intervalDays;

  /// A calendar day, at local midnight.
  final DateTime nextDueOn;

  /// Days from [now]'s calendar day to [nextDueOn]: positive ahead, zero
  /// today, negative late. Counted on dates, so daylight saving never makes
  /// it off by one.
  int daysUntil(DateTime now) =>
      DateTime.utc(nextDueOn.year, nextDueOn.month, nextDueOn.day)
          .difference(DateTime.utc(now.year, now.month, now.day))
          .inDays;

  /// Today or earlier: the home reminder shows.
  bool isDue(DateTime now) => daysUntil(now) <= 0;
}

/// `reason` of a quick request. [unknown] keeps a reason the app does not
/// know yet instead of dropping the request.
enum QuickRequestReason {
  specialOccasion('special_occasion'),
  foodUnavailable('food_unavailable'),
  craving('craving'),
  cannotContinue('cannot_continue'),
  other('other'),
  unknown('');

  const QuickRequestReason(this.wire);

  final String wire;

  /// The reasons a patient can choose, in the spec's order.
  static const List<QuickRequestReason> choices = [
    specialOccasion,
    foodUnavailable,
    craving,
    cannotContinue,
    other,
  ];

  static QuickRequestReason fromWire(Object? value) =>
      values.firstWhere((r) => r != unknown && r.wire == value,
          orElse: () => unknown);
}

enum QuickRequestStatus { open, answered, closed, unknown }

class QuickRequest {
  const QuickRequest({
    required this.id,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.note,
    this.occasionDate,
    this.response,
    this.respondedAt,
  });

  final int id;
  final QuickRequestReason reason;
  final QuickRequestStatus status;
  final DateTime createdAt;
  final String? note;

  /// Only for [QuickRequestReason.specialOccasion].
  final DateTime? occasionDate;

  /// The nutritionist's reply. Shown whenever present, closed requests too.
  final String? response;
  final DateTime? respondedAt;

  bool get isOpen => status == QuickRequestStatus.open;
}

/// What the patient sends from the quick-request form.
class QuickRequestDraft {
  const QuickRequestDraft({required this.reason, this.note, this.occasionDate});

  static const int noteMaxLength = 280;

  /// Requests a patient can send per day (`quick_request_limit`, 429).
  static const int dailyLimit = 5;

  final QuickRequestReason reason;
  final String? note;

  /// Sent only with [QuickRequestReason.specialOccasion].
  final DateTime? occasionDate;
}
