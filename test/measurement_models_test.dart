import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/data/mock/measurement_mock_data.dart';

void main() {
  test('weight trend is chronologically ordered', () {
    final pts = MeasurementMockData.weightTrend;
    for (int i = 1; i < pts.length; i++) {
      expect(pts[i].date.isAfter(pts[i - 1].date), isTrue);
    }
  });

  test('current weight equals the latest trend point', () {
    expect(MeasurementMockData.weightTrend.last.kg, MeasurementMockData.currentWeight);
  });

  test('every guide part has exactly 3 steps and a unique key', () {
    final keys = MeasurementGuideData.parts.map((p) => p.key).toSet();
    expect(keys.length, MeasurementGuideData.parts.length);
    for (final p in MeasurementGuideData.parts) {
      expect(p.steps.length, 3);
    }
  });
}
