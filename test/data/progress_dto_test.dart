import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/data/models/progress_dto.dart';

/// One weight reading as the trend sends it (API guide 8).
Map<String, dynamic> _point(
  Object? date,
  Object? weight, {
  Object? source = 'clinic-analyser',
}) =>
    {
      'recorded_at': date,
      'weight_kg': weight,
      'source': source,
      'is_late': false,
      'edited_at': null,
    };

/// A whole answer, with every block the screen reads.
Map<String, dynamic> _answer({
  List<Object?> trend = const [],
  Object? latest,
  Object? change,
  Object? percent,
  Object? changePp,
}) =>
    {
      'weight_trend': trend,
      'body_composition': {'latest': latest, 'change': change},
      'adherence': {
        'from': '2026-09-30',
        'to': '2026-10-06',
        'adherence_percent': percent,
        'change_pp': changePp,
      },
      'daily_calories': <Object?>[],
    };

void main() {
  test('the trend is read oldest first, and each reading keeps its source', () {
    final snapshot = ProgressDto.fromJson(_answer(trend: [
      _point('2026-10-06', 83.2),
      _point('2026-09-30', 84),
      _point('2026-10-06', 82.5, source: 'self-reported'),
    ]));

    expect(snapshot.weightTrend.first.weightKg, 84);
    expect(snapshot.weightTrend.first.recordedAt, DateTime(2026, 9, 30));
    final october = snapshot.weightTrend
        .where((p) => p.recordedAt == DateTime(2026, 10, 6));
    expect(october.map((p) => p.isClinic), unorderedEquals([true, false]));
  });

  test('a reading without a date or a weight is skipped', () {
    final snapshot = ProgressDto.fromJson(_answer(trend: [
      _point(null, 80),
      _point('2026-10-01', null),
      _point('not a date', 81),
      'not a reading',
    ]));

    expect(snapshot.weightTrend, isEmpty);
    expect(snapshot.latestWeightKg, isNull);
  });

  test(
      'the latest weight is the composition block\'s, or else the newest reading',
      () {
    final fromBlock = ProgressDto.fromJson(_answer(
      trend: [_point('2026-10-06', 83.2)],
      latest: {'weight_kg': 82.0},
    ));
    final fromTrend = ProgressDto.fromJson(_answer(
      trend: [_point('2026-09-30', 84), _point('2026-10-06', 83.2)],
    ));

    expect(fromBlock.latestWeightKg, 82.0);
    expect(fromTrend.latestWeightKg, 83.2);
  });

  test('the change is null when the server sends none, and signed otherwise',
      () {
    final none = ProgressDto.fromJson(_answer());
    final lost = ProgressDto.fromJson(_answer(change: {'weight_kg': -2}));

    expect(none.weightChangeKg, isNull);
    expect(lost.weightChangeKg, -2.0);
  });

  test('adherence with nothing logged is null, not zero', () {
    final empty = ProgressDto.fromJson(_answer());
    final logged = ProgressDto.fromJson(_answer(percent: 72, changePp: -13));

    expect(empty.adherence.percent, isNull);
    expect(logged.adherence.percent, 72);
    expect(logged.adherence.changePp, -13);
  });

  test('an empty answer reads as nothing to show, not as an error', () {
    final snapshot = ProgressDto.fromJson(const {});

    expect(snapshot.weightTrend, isEmpty);
    expect(snapshot.latestWeightKg, isNull);
    expect(snapshot.weightChangeKg, isNull);
    expect(snapshot.adherence.percent, isNull);
  });
}
