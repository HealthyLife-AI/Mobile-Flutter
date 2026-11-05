import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/time/date_only.dart';

void main() {
  test('formats the date parts as YYYY-MM-DD, zero-padded', () {
    expect(dateOnly(DateTime(2026, 1, 5, 23, 59)), '2026-01-05');
    expect(dateOnly(DateTime(2026, 10, 13)), '2026-10-13');
  });

  test('ignores the time of day', () {
    expect(dateOnly(DateTime(2026, 10, 7, 0, 0)),
        dateOnly(DateTime(2026, 10, 7, 23, 59)));
  });
}
