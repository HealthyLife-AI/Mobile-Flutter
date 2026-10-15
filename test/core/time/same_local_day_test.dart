import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/time/date_only.dart';

void main() {
  test('two times on the same device day are the same day', () {
    expect(
      isSameLocalDay(
          DateTime(2026, 10, 14, 0, 5), DateTime(2026, 10, 14, 23, 55)),
      isTrue,
    );
  });

  test('a time just after midnight is the next day', () {
    expect(
      isSameLocalDay(
          DateTime(2026, 10, 14, 23, 59), DateTime(2026, 10, 15, 0, 1)),
      isFalse,
    );
  });

  test('the same day one month apart is not the same day', () {
    expect(
      isSameLocalDay(DateTime(2026, 10, 14), DateTime(2026, 11, 14)),
      isFalse,
    );
  });
}
