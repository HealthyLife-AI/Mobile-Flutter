/// Where a tapped push opens (API guide 10.3).
///
/// Pure Dart, so the mapping can be unit tested without Flutter or Firebase.
enum PushDestination {
  /// Home tab. `follow_up_resumed`.
  home,

  /// My plan. `plan_activated`, `plan_updated`.
  myPlan,

  /// My health profile. `proposal_decided`.
  healthProfile,

  /// Appointments. `appointment_cancelled`, `appointment_rescheduled`.
  appointments,

  /// Log a meal. `log_reminder`.
  logMeal,

  /// The nutritionist's notes. `review_new`, `review_updated`.
  notes,

  /// Notification inbox. Used for unknown types, so older app versions keep
  /// working when new types are added.
  inbox,
}

/// The destination for a push `type`. An unknown or missing type opens the
/// inbox (API guide 10.3).
PushDestination destinationForType(String? type) => switch (type) {
      'plan_activated' || 'plan_updated' => PushDestination.myPlan,
      'proposal_decided' => PushDestination.healthProfile,
      'appointment_cancelled' ||
      'appointment_rescheduled' =>
        PushDestination.appointments,
      'follow_up_resumed' => PushDestination.home,
      'log_reminder' => PushDestination.logMeal,
      'review_new' || 'review_updated' => PushDestination.notes,
      _ => PushDestination.inbox,
    };

/// True for a push that changes an appointment. The appointment reminders are
/// planned again after one (API guide 10.6).
bool isAppointmentChangePush(Map<String, dynamic>? data) =>
    destinationForType(PushTap.fromData(data)?.type) ==
    PushDestination.appointments;

/// True for a push that activates or changes the plan. The plan is read again
/// after one (API guide 5.1, 10.3).
bool isPlanChangePush(Map<String, dynamic>? data) =>
    destinationForType(PushTap.fromData(data)?.type) == PushDestination.myPlan;

/// What a tapped push carries. Every `data` value arrives as a string (10.4).
class PushTap {
  const PushTap({this.notificationId, this.type, this.reviewId});

  /// The inbox row to mark read, or null when the push had none.
  final String? notificationId;

  /// The `type` from 10.3, or null.
  final String? type;

  /// The note a `review_new` or `review_updated` push names (`review_id`), or
  /// null.
  final String? reviewId;

  /// Reads a tap from the message `data`. Returns null when neither the
  /// notification id nor the type is present, so a plain notification opens
  /// nothing. Non-string values are ignored.
  static PushTap? fromData(Map<String, dynamic>? data) {
    if (data == null) return null;
    final id = _text(data['notification_id']);
    final type = _text(data['type']);
    if (id == null && type == null) return null;
    return PushTap(
      notificationId: id,
      type: type,
      reviewId: _text(data['review_id']),
    );
  }

  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
