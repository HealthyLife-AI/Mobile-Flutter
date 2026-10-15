/// The patient's notification settings (API guide 10.5). Pure Dart.
///
/// The defaults are the server's: every category on, quiet hours on from
/// 22:00 to 07:00.
class NotificationPreferences {
  const NotificationPreferences({
    this.meals = true,
    this.measurements = true,
    this.nutritionist = true,
    this.plan = true,
    this.quietHoursEnabled = true,
    this.quietStartMinute = 22 * 60,
    this.quietEndMinute = 7 * 60,
  });

  final bool meals;
  final bool measurements;
  final bool nutritionist;
  final bool plan;

  final bool quietHoursEnabled;

  /// Minutes after midnight, local time. A range like 22:00–07:00 spans
  /// midnight.
  final int quietStartMinute;
  final int quietEndMinute;

  /// Whether [minuteOfDay] falls in the quiet hours, when they are on.
  bool isQuietAt(int minuteOfDay) {
    if (!quietHoursEnabled || quietStartMinute == quietEndMinute) return false;
    if (quietStartMinute < quietEndMinute) {
      return minuteOfDay >= quietStartMinute && minuteOfDay < quietEndMinute;
    }
    return minuteOfDay >= quietStartMinute || minuteOfDay < quietEndMinute;
  }

  NotificationPreferences copyWith({
    bool? meals,
    bool? measurements,
    bool? nutritionist,
    bool? plan,
    bool? quietHoursEnabled,
    int? quietStartMinute,
    int? quietEndMinute,
  }) =>
      NotificationPreferences(
        meals: meals ?? this.meals,
        measurements: measurements ?? this.measurements,
        nutritionist: nutritionist ?? this.nutritionist,
        plan: plan ?? this.plan,
        quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
        quietStartMinute: quietStartMinute ?? this.quietStartMinute,
        quietEndMinute: quietEndMinute ?? this.quietEndMinute,
      );

  @override
  bool operator ==(Object other) =>
      other is NotificationPreferences &&
      other.meals == meals &&
      other.measurements == measurements &&
      other.nutritionist == nutritionist &&
      other.plan == plan &&
      other.quietHoursEnabled == quietHoursEnabled &&
      other.quietStartMinute == quietStartMinute &&
      other.quietEndMinute == quietEndMinute;

  @override
  int get hashCode => Object.hash(meals, measurements, nutritionist, plan,
      quietHoursEnabled, quietStartMinute, quietEndMinute);
}
