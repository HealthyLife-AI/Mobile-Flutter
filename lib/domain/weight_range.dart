import 'entities/measurement_entities.dart';

/// The weight points in the last [days] days, today included, the same window
/// the progress screen counts. A null [days] keeps every point.
List<WeightPoint> weightPointsInRange(
  List<WeightPoint> points, {
  required int? days,
  required DateTime now,
}) {
  if (days == null) return points;
  final start =
      DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));
  return points.where((point) => !point.date.isBefore(start)).toList();
}
