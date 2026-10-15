import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/domain/entities/measurement_entities.dart';
import 'package:healthylife_ai/domain/weight_range.dart';

void main() {
  // Today is 14 October, at 11:00 on the device.
  final now = DateTime(2026, 10, 14, 11);

  final points = [
    WeightPoint(date: DateTime(2026, 9, 14, 9), kg: 80), // 30 days back, out
    WeightPoint(date: DateTime(2026, 9, 15), kg: 79), // first day of 30, in
    WeightPoint(date: DateTime(2026, 10, 14, 8), kg: 78), // today, in
  ];

  group('weightPointsInRange', () {
    test('a null window keeps every point', () {
      expect(weightPointsInRange(points, days: null, now: now), points);
    });

    test('30 days keeps today and the 29 days before it', () {
      final kept = weightPointsInRange(points, days: 30, now: now);

      expect(kept.map((p) => p.kg), [79, 78]);
    });

    test('90 days keeps the older point too', () {
      final kept = weightPointsInRange(points, days: 90, now: now);

      expect(kept.map((p) => p.kg), [80, 79, 78]);
    });

    test('an empty list stays empty', () {
      expect(weightPointsInRange(const [], days: 30, now: now), isEmpty);
    });
  });
}
