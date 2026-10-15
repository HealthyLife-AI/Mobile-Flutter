import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/utils/uuid_v4.dart';

void main() {
  // Version 4 in the third group, RFC 4122 variant (8, 9, a or b) in the fourth.
  final shape = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');

  test('is a version 4 UUID in the usual 8-4-4-4-12 form', () {
    for (var i = 0; i < 50; i++) {
      expect(newUuidV4(), matches(shape));
    }
  });

  test('two keys are not the same', () {
    final keys = {for (var i = 0; i < 200; i++) newUuidV4()};
    expect(keys, hasLength(200));
  });

  test('a seeded source gives the same key, so a test can pin one', () {
    expect(newUuidV4(Random(7)), newUuidV4(Random(7)));
  });
}
