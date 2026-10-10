/// Domain entities for body measurements and the measurement guide.
/// Pure Dart â€” no Flutter imports, no mock data.

/// Mock data mirroring POST /me/measurements (Mobile API Reference, 3.4)
/// and GET /clients/{id}/progress (4.2) — weight_trend + body_composition.
/// `source` distinguishes clinic-analyser vs self-reported readings, which
/// the API doc explicitly requires to be shown differently (BR-13).
class WeightPoint {
  final DateTime date;
  final double kg;
  final bool clinicVerified;
  const WeightPoint({required this.date, required this.kg, this.clinicVerified = false});
}

class CircumferenceStat {
  final String label;
  final double valueCm;
  final double? deltaCm; // null/0 => "ثابت ومستقر"
  const CircumferenceStat({required this.label, required this.valueCm, this.deltaCm});
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


/// A single saved measurement reading (weight + optional circumferences).
class MeasurementEntry {
  const MeasurementEntry({
    required this.id,
    required this.recordedAt,
    this.weightKg,
    this.waistCm,
    this.hipCm,
    this.thighCm,
    this.armCm,
  });

  final String id;
  final DateTime recordedAt;
  final double? weightKg;
  final double? waistCm;
  final double? hipCm;
  final double? thighCm;
  final double? armCm;

  Map<String, dynamic> toJson() => {
        'id': id,
        'recordedAt': recordedAt.toIso8601String(),
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
    double? d(String key) => json[key] is num ? (json[key] as num).toDouble() : null;
    return MeasurementEntry(
      id: id,
      recordedAt: DateTime.tryParse(recordedAt) ?? DateTime.now(),
      weightKg: d('weightKg'),
      waistCm: d('waistCm'),
      hipCm: d('hipCm'),
      thighCm: d('thighCm'),
      armCm: d('armCm'),
    );
  }
}

/// Everything the measurements screen needs: baseline (clinic) data plus
/// locally saved readings, ready for rendering.
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

  final double currentWeight;
  final double previousWeight;
  final List<WeightPoint> weightTrend;
  final List<CircumferenceStat> circumference;
  final int daysLoggedThisWeek;
  final int daysLoggedThisMonth;
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
