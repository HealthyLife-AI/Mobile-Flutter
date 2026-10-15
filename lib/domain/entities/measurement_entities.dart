/// Domain entities for body measurements and the measurement guide.
/// Pure Dart: no Flutter imports, no mock data.
library;

/// One point on the weight trend. [clinicVerified] is true for a reading taken
/// by the clinic's analyser, which the API requires to be shown differently
/// (BR-13).
class WeightPoint {
  final DateTime date;
  final double kg;
  final bool clinicVerified;
  const WeightPoint(
      {required this.date, required this.kg, this.clinicVerified = false});
}

/// The four body parts with a circumference (7.1). The screen names each one in
/// the patient's language.
enum CircumferencePart { waist, hip, thigh, arm }

class CircumferenceStat {
  final CircumferencePart part;
  final double valueCm;
  final double? deltaCm; // null/0 => "ثابت ومستقر"
  const CircumferenceStat(
      {required this.part, required this.valueCm, this.deltaCm});
}

class GuideStep {
  final String text;
  const GuideStep(this.text);
}

class MeasurementGuidePart {
  final String key; // waist | hip | thigh | arm
  final String labelAr;
  final String labelEn;
  final String positionBadge;
  final String cornerHint;
  final List<GuideStep> steps;
  const MeasurementGuidePart({
    required this.key,
    required this.labelAr,
    required this.labelEn,
    required this.positionBadge,
    required this.cornerHint,
    required this.steps,
  });
}

/// Who took a reading (API guide 7.1, `source`).
enum ReadingSource { selfReported, clinicAnalyser }

/// One body reading on one day: a weight and optional circumferences.
///
/// [pending] is true for a reading still waiting in the offline queue (14), so
/// the server does not have it yet.
class MeasurementEntry {
  const MeasurementEntry({
    required this.id,
    required this.recordedAt,
    this.source = ReadingSource.selfReported,
    this.pending = false,
    this.weightKg,
    this.waistCm,
    this.hipCm,
    this.thighCm,
    this.armCm,
  });

  final String id;
  final DateTime recordedAt;
  final ReadingSource source;
  final bool pending;
  final double? weightKg;
  final double? waistCm;
  final double? hipCm;
  final double? thighCm;
  final double? armCm;

  Map<String, dynamic> toJson() => {
        'id': id,
        'recordedAt': recordedAt.toIso8601String(),
        'source': source.name,
        if (weightKg != null) 'weightKg': weightKg,
        if (waistCm != null) 'waistCm': waistCm,
        if (hipCm != null) 'hipCm': hipCm,
        if (thighCm != null) 'thighCm': thighCm,
        if (armCm != null) 'armCm': armCm,
      };

  static MeasurementEntry? fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final recordedAt = json['recordedAt'];
    if (id is! String || recordedAt is! String) return null;
    double? d(String key) =>
        json[key] is num ? (json[key] as num).toDouble() : null;
    return MeasurementEntry(
      id: id,
      recordedAt: DateTime.tryParse(recordedAt) ?? DateTime.now(),
      source: json['source'] == ReadingSource.clinicAnalyser.name
          ? ReadingSource.clinicAnalyser
          : ReadingSource.selfReported,
      weightKg: d('weightKg'),
      waistCm: d('waistCm'),
      hipCm: d('hipCm'),
      thighCm: d('thighCm'),
      armCm: d('armCm'),
    );
  }
}

/// Everything the measurements screen needs, computed from the readings.
///
/// The weights are null until there are readings to take them from: the
/// current weight needs one weight, the previous one needs two.
class MeasurementSnapshot {
  const MeasurementSnapshot({
    required this.currentWeight,
    required this.previousWeight,
    required this.weightTrend,
    required this.circumference,
    required this.daysLoggedThisWeek,
    required this.daysLoggedThisMonth,
    required this.savedEntries,
  });

  final double? currentWeight;
  final double? previousWeight;
  final List<WeightPoint> weightTrend;
  final List<CircumferenceStat> circumference;

  /// Distinct days with the patient's own reading over the last 7 days,
  /// today included.
  final int daysLoggedThisWeek;

  /// The same over the last 30 days, today included (a rolling window, not
  /// the calendar month).
  final int daysLoggedThisMonth;

  /// Every reading, clinic and self-reported, oldest first.
  final List<MeasurementEntry> savedEntries;

  bool get isEmpty => weightTrend.isEmpty && savedEntries.isEmpty;

  MeasurementSnapshot copyWith({
    double? currentWeight,
    double? previousWeight,
    List<WeightPoint>? weightTrend,
    List<CircumferenceStat>? circumference,
    int? daysLoggedThisWeek,
    int? daysLoggedThisMonth,
    List<MeasurementEntry>? savedEntries,
  }) =>
      MeasurementSnapshot(
        currentWeight: currentWeight ?? this.currentWeight,
        previousWeight: previousWeight ?? this.previousWeight,
        weightTrend: weightTrend ?? this.weightTrend,
        circumference: circumference ?? this.circumference,
        daysLoggedThisWeek: daysLoggedThisWeek ?? this.daysLoggedThisWeek,
        daysLoggedThisMonth: daysLoggedThisMonth ?? this.daysLoggedThisMonth,
        savedEntries: savedEntries ?? this.savedEntries,
      );
}
