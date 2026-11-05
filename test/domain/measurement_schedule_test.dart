import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/domain/entities/measurement_entities.dart';
import 'package:healthylife_ai/domain/measurement_schedule.dart';

MeasurementEntry _reading(String id, DateTime day,
        {ReadingSource source = ReadingSource.selfReported}) =>
    MeasurementEntry(id: id, recordedAt: day, source: source, weightKg: 80);

MeasurementSnapshot _snapshot(List<MeasurementEntry> readings) =>
    MeasurementSnapshot(
      currentWeight: readings.isEmpty ? null : 80,
      previousWeight: null,
      weightTrend: [
        for (final r in readings) WeightPoint(date: r.recordedAt, kg: 80),
      ],
      circumference: const [],
      daysLoggedThisWeek: 0,
      daysLoggedThisMonth: 0,
      savedEntries: readings,
    );

void main() {
  // Today is Thursday 15 October, at 10:00 on the device.
  final now = DateTime(2026, 10, 15, 10);

  test('with no reading, the first one is due now', () {
    final empty = _snapshot(const []);

    expect(nextMeasurementDay(empty), isNull);
    expect(isMeasurementDue(empty, now: now), isTrue);
  });

  test('the next reading is due a week after the latest one', () {
    final snapshot = _snapshot([
      _reading('a', DateTime(2026, 10, 1)),
      _reading('b', DateTime(2026, 10, 9)),
    ]);

    expect(nextMeasurementDay(snapshot), DateTime(2026, 10, 16));
    expect(isMeasurementDue(snapshot, now: now), isFalse);
    expect(
        isMeasurementDue(snapshot, now: DateTime(2026, 10, 16, 0, 5)), isTrue);
  });

  test('exactly a week later is due, whatever the hour', () {
    final snapshot = _snapshot([_reading('a', DateTime(2026, 10, 8))]);

    expect(isMeasurementDue(snapshot, now: DateTime(2026, 10, 15)), isTrue);
    expect(isMeasurementDue(snapshot, now: DateTime(2026, 10, 14, 23, 59)),
        isFalse);
  });

  test('a clinic reading counts as much as the patient\'s own', () {
    final snapshot = _snapshot([
      _reading('own', DateTime(2026, 10, 1)),
      _reading('clinic', DateTime(2026, 10, 12),
          source: ReadingSource.clinicAnalyser),
    ]);

    expect(latestReading(snapshot)!.id, 'clinic');
    expect(isMeasurementDue(snapshot, now: now), isFalse);
  });

  test('the latest of two readings on one day is the later one listed', () {
    final day = DateTime(2026, 10, 12);
    final snapshot = _snapshot([_reading('a', day), _reading('b', day)]);

    expect(latestReading(snapshot)!.id, 'b');
  });
}
