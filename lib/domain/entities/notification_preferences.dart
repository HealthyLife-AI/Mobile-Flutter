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
    this.morning = true,
    this.education = true,
    this.categoryOrder = defaultCategoryOrder,
    this.quietHoursEnabled = true,
    this.quietStartMinute = 22 * 60,
    this.quietEndMinute = 7 * 60,
  });

  /// The categories shown before the server has answered.
  static const List<String> defaultCategoryOrder = [
    'meals',
    'measurements',
    'nutritionist',
    'plan',
  ];

  /// Every category key the app has a label for.
  static const Set<String> knownCategories = {
    'meals',
    'measurements',
    'nutritionist',
    'plan',
    'morning',
    'education',
  };

  final bool meals;
  final bool measurements;
  final bool nutritionist;
  final bool plan;

  /// The morning message (spec, phase 3). On by default.
  final bool morning;

  /// The nutritionist's advice posts (spec, phase 3). On by default.
  final bool education;

  /// The categories the server returned, in its order: only these are shown
  /// and sent back. Unknown keys are left out.
  final List<String> categoryOrder;

  /// Whether [key] is on.
  bool isOn(String key) => switch (key) {
        'meals' => meals,
        'measurements' => measurements,
        'nutritionist' => nutritionist,
        'plan' => plan,
        'morning' => morning,
        'education' => education,
        _ => false,
      };

  /// A copy with [key] set to [value].
  NotificationPreferences withCategory(String key, bool value) => switch (key) {
        'meals' => copyWith(meals: value),
        'measurements' => copyWith(measurements: value),
        'nutritionist' => copyWith(nutritionist: value),
        'plan' => copyWith(plan: value),
        'morning' => copyWith(morning: value),
        'education' => copyWith(education: value),
        _ => this,
      };

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
    bool? morning,
    bool? education,
    List<String>? categoryOrder,
    bool? quietHoursEnabled,
    int? quietStartMinute,
    int? quietEndMinute,
  }) =>
      NotificationPreferences(
        meals: meals ?? this.meals,
        measurements: measurements ?? this.measurements,
        nutritionist: nutritionist ?? this.nutritionist,
        plan: plan ?? this.plan,
        morning: morning ?? this.morning,
        education: education ?? this.education,
        categoryOrder: categoryOrder ?? this.categoryOrder,
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
      other.morning == morning &&
      other.education == education &&
      _sameOrder(other.categoryOrder, categoryOrder) &&
      other.quietHoursEnabled == quietHoursEnabled &&
      other.quietStartMinute == quietStartMinute &&
      other.quietEndMinute == quietEndMinute;

  @override
  int get hashCode => Object.hash(
      meals,
      measurements,
      nutritionist,
      plan,
      morning,
      education,
      Object.hashAll(categoryOrder),
      quietHoursEnabled,
      quietStartMinute,
      quietEndMinute);

  static bool _sameOrder(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
