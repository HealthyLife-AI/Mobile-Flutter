import '../../domain/entities/progress_entities.dart';

/// Reads the `GET /me/progress` answer (API guide 8). The reading is lenient:
/// a missing or wrongly typed field is left out, and a weight point without a
/// date or a weight is skipped. The server decides the values; the app only
/// shows them.
class ProgressDto {
  const ProgressDto._();

  static ProgressSnapshot fromJson(Map<String, dynamic> json) {
    final trend = _weightTrend(json['weight_trend']);
    final composition = _map(json['body_composition']);
    final latest = _map(composition?['latest']);
    final change = _map(composition?['change']);
    final adherence = _map(json['adherence']);

    return ProgressSnapshot(
      weightTrend: trend,
      // The composition block's own latest weight, or, when it has none, the
      // newest point on the trend.
      latestWeightKg: _number(latest?['weight_kg'])?.toDouble() ??
          (trend.isEmpty ? null : trend.last.weightKg),
      weightChangeKg: _number(change?['weight_kg'])?.toDouble(),
      adherence: AdherenceSummary(
        percent: _number(adherence?['adherence_percent'])?.round(),
        changePp: _number(adherence?['change_pp'])?.round(),
      ),
    );
  }

  /// Oldest first. The server sends it in that order, but the sort does not
  /// rely on it.
  static List<ProgressWeightPoint> _weightTrend(Object? raw) {
    if (raw is! List) return const [];
    final points = <ProgressWeightPoint>[];
    for (final item in raw) {
      final map = _map(item);
      if (map == null) continue;
      final date = _date(map['recorded_at']);
      final weight = _number(map['weight_kg']);
      if (date == null || weight == null) continue;
      points.add(ProgressWeightPoint(
        recordedAt: date,
        weightKg: weight.toDouble(),
        source: _text(map['source']) ?? '',
      ));
    }
    points.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    return points;
  }

  static Map<String, dynamic>? _map(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  static num? _number(Object? value) => value is num ? value : null;

  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// A `YYYY-MM-DD` date at local midnight, or null when it cannot be read.
  static DateTime? _date(Object? value) {
    if (value is! String) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }
}
