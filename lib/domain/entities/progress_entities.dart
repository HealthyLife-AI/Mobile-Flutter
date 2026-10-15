/// What the progress screen shows, from `GET /me/progress` (API guide 8).

/// One weight reading on the trend. [recordedAt] is the reading's calendar
/// date, at local midnight. A date can have two readings: the clinic's and the
/// patient's own, which the server marks `self-reported` (7.1).
class ProgressWeightPoint {
  const ProgressWeightPoint({
    required this.recordedAt,
    required this.weightKg,
    required this.source,
  });

  final DateTime recordedAt;
  final double weightKg;

  /// The server's name for where the reading came from.
  final String source;

  /// True for a reading taken at the clinic. Every source other than the
  /// patient's own counts as the clinic's.
  bool get isClinic => source != selfReportedSource;

  static const String selfReportedSource = 'self-reported';
}

/// The share of logged food that was on the plan (API guide 8, adherence).
class AdherenceSummary {
  const AdherenceSummary({required this.percent, required this.changePp});

  /// The on-plan share of what was logged. Null when nothing was logged, which
  /// is not the same as 0.
  final int? percent;

  /// The change from the previous period, in percentage points. Null when
  /// either period has no data.
  final int? changePp;
}

class ProgressSnapshot {
  const ProgressSnapshot({
    required this.weightTrend,
    required this.latestWeightKg,
    required this.weightChangeKg,
    required this.adherence,
  });

  /// Oldest first, ready to plot.
  final List<ProgressWeightPoint> weightTrend;

  /// The weight the patient is at now, or null when there is no reading.
  final double? latestWeightKg;

  /// The change over the window. Null with fewer than two readings.
  final double? weightChangeKg;

  final AdherenceSummary adherence;
}
