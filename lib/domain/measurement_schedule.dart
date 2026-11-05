import 'entities/measurement_entities.dart';

/// Days between two readings: the weekly weigh-in (API guide 10.6).
const int measurementIntervalDays = 7;

/// The latest reading in [snapshot], of either source (a clinic reading counts
/// as much as the patient's own), or null when there is none.
MeasurementEntry? latestReading(MeasurementSnapshot snapshot) {
  MeasurementEntry? latest;
  for (final entry in snapshot.savedEntries) {
    if (latest == null || !entry.recordedAt.isBefore(latest.recordedAt)) {
      latest = entry;
    }
  }
  return latest;
}

/// The day the next reading is due: a week after the latest one. Null when
/// there is no reading yet, in which case the first one is due now.
DateTime? nextMeasurementDay(MeasurementSnapshot snapshot) {
  final at = latestReading(snapshot)?.recordedAt ??
      (snapshot.weightTrend.isEmpty ? null : snapshot.weightTrend.last.date);
  if (at == null) return null;
  return DateTime(at.year, at.month, at.day + measurementIntervalDays);
}

/// Whether the patient should take a reading today: they have none yet, or a
/// week has passed since the latest one.
bool isMeasurementDue(MeasurementSnapshot snapshot, {required DateTime now}) {
  final due = nextMeasurementDay(snapshot);
  if (due == null) return true;
  return !DateTime(now.year, now.month, now.day).isBefore(due);
}
