/// Achievements computed from what the patient actually logged: meals on
/// this device, readings and the goal on the server. Nothing is awarded that
/// the data does not show. Pure Dart.
library;

enum AchievementKind {
  firstMeal,
  streak3,
  streak7,
  days30,
  firstReading,
  fiveReadings,
  firstKilos,
  halfway,
  goalReached,
}

class Achievement {
  const Achievement(
      {required this.kind, required this.current, required this.target});

  final AchievementKind kind;

  /// How far along, in the achievement's own unit (days, readings, kg×10).
  final double current;
  final double target;

  bool get earned => current >= target;

  /// 0..1 for the progress bar.
  double get progress => target <= 0 ? 0 : (current / target).clamp(0, 1);
}

/// What the achievements are computed from.
class AchievementInputs {
  const AchievementInputs({
    required this.mealDays,
    required this.readingWeights,
    this.goalType,
    this.targetWeightKg,
    this.today,
  });

  /// The days (any time of day) a meal was logged.
  final List<DateTime> mealDays;

  /// Weight of each reading, oldest first.
  final List<double> readingWeights;

  /// `weight_loss`, `weight_gain`, or anything else (no direction).
  final String? goalType;
  final double? targetWeightKg;

  /// For tests; defaults to now.
  final DateTime? today;
}

DateTime _day(DateTime d) => DateTime.utc(d.year, d.month, d.day);

/// The longest run of consecutive logged days.
int bestStreak(Iterable<DateTime> days) {
  final sorted = days.map(_day).toSet().toList()..sort();
  var best = 0;
  var run = 0;
  DateTime? previous;
  for (final day in sorted) {
    run =
        previous != null && day.difference(previous).inDays == 1 ? run + 1 : 1;
    if (run > best) best = run;
    previous = day;
  }
  return best;
}

/// The run of consecutive logged days ending today, or yesterday when
/// today has no log yet (the streak is not lost until the day is over).
int currentStreak(Iterable<DateTime> days, {DateTime? today}) {
  final set = days.map(_day).toSet();
  var cursor = _day(today ?? DateTime.now());
  if (!set.contains(cursor)) cursor = cursor.subtract(const Duration(days: 1));
  var run = 0;
  while (set.contains(cursor)) {
    run++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return run;
}

List<Achievement> computeAchievements(AchievementInputs input) {
  final distinctDays = input.mealDays.map(_day).toSet().length;
  final streak = bestStreak(input.mealDays);
  final readings = input.readingWeights.length;

  final list = <Achievement>[
    Achievement(
        kind: AchievementKind.firstMeal,
        current: input.mealDays.isEmpty ? 0 : 1,
        target: 1),
    Achievement(
        kind: AchievementKind.streak3, current: streak.toDouble(), target: 3),
    Achievement(
        kind: AchievementKind.streak7, current: streak.toDouble(), target: 7),
    Achievement(
        kind: AchievementKind.days30,
        current: distinctDays.toDouble(),
        target: 30),
    Achievement(
        kind: AchievementKind.firstReading,
        current: readings > 0 ? 1 : 0,
        target: 1),
    Achievement(
        kind: AchievementKind.fiveReadings,
        current: readings.toDouble(),
        target: 5),
  ];

  // Weight milestones need a direction, and at least one reading to start.
  final sign = switch (input.goalType) {
    'weight_loss' => -1.0,
    'weight_gain' => 1.0,
    _ => 0.0,
  };
  if (sign != 0 && readings > 0) {
    final start = input.readingWeights.first;
    final latest = input.readingWeights.last;
    final moved = ((latest - start) * sign).clamp(0.0, double.infinity);
    list.add(Achievement(
        kind: AchievementKind.firstKilos, current: moved, target: 2));
    final target = input.targetWeightKg;
    if (target != null) {
      final total = ((target - start) * sign);
      if (total > 0) {
        list
          ..add(Achievement(
              kind: AchievementKind.halfway, current: moved, target: total / 2))
          ..add(Achievement(
              kind: AchievementKind.goalReached,
              current: moved,
              target: total));
      }
    }
  }
  return list;
}
