import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/sync/pending_write.dart';
import 'package:healthylife_ai/data/models/measurement_dto.dart';
import 'package:healthylife_ai/domain/entities/measurement_entities.dart';

void main() {
  test('a server reading keeps its id, day, source and values (7.1)', () {
    final reading = MeasurementDto.readingFromJson({
      'id': 9,
      'recorded_at': '2026-10-07',
      'source': 'self-reported',
      'is_late': false,
      'edited_at': null,
      'weight_kg': 79.5,
      'body_fat_percent': null,
      'hip_cm': 100,
      'waist_cm': null,
      'deletable_until': '2026-10-14T08:00:12+00:00',
    });

    expect(reading.id, '9');
    expect(reading.recordedAt, DateTime(2026, 10, 7));
    expect(reading.source, ReadingSource.selfReported);
    expect(reading.weightKg, 79.5);
    expect(reading.hipCm, 100);
    expect(reading.waistCm, isNull);
    expect(reading.pending, isFalse);
  });

  test('a clinic reading is marked as the clinic\'s', () {
    final reading = MeasurementDto.readingFromJson({
      'id': 3,
      'recorded_at': '2026-09-30',
      'source': 'clinic-analyser',
      'weight_kg': 84,
    });

    expect(reading.source, ReadingSource.clinicAnalyser);
    expect(reading.weightKg, 84);
  });

  test('a list answer that is not a list, or holds a non-object, is refused',
      () {
    expect(() => MeasurementDto.readingsFromJson({'id': 1}),
        throwsA(isA<ParseException>()));
    expect(() => MeasurementDto.readingsFromJson([42]),
        throwsA(isA<ParseException>()));
  });

  test('a reading without an id or a readable date is refused', () {
    expect(
      () => MeasurementDto.readingFromJson({'recorded_at': '2026-10-07'}),
      throwsA(isA<ParseException>()),
    );
    expect(
      () => MeasurementDto.readingFromJson({'id': 1, 'recorded_at': 'soon'}),
      throwsA(isA<ParseException>()),
    );
  });

  test('a queued body is read back as a waiting reading', () {
    final write = PendingWrite(
      id: 'w1',
      path: 'me/measurements',
      body: const {
        'weight_kg': 81.0,
        'waist_cm': 86.0,
        'recorded_at': '2026-10-06',
      },
      queuedAt: DateTime.utc(2026, 10, 6, 9),
    );

    final reading = MeasurementDto.waitingFromWrite(write)!;

    expect(reading.id, 'waiting-w1');
    expect(reading.recordedAt, DateTime(2026, 10, 6));
    expect(reading.weightKg, 81.0);
    expect(reading.waistCm, 86.0);
    expect(reading.source, ReadingSource.selfReported);
    expect(reading.pending, isTrue);
  });

  test('a queued body without a date is skipped', () {
    final write = PendingWrite(
      id: 'w2',
      path: 'me/measurements',
      body: const {'weight_kg': 81.0},
      queuedAt: DateTime.utc(2026, 10, 6),
    );

    expect(MeasurementDto.waitingFromWrite(write), isNull);
  });
}
