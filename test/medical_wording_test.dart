import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The app explains and follows a plan; it does not diagnose or treat. These
/// words claim more than that, so they must not come back into the strings.
void main() {
  final banned = {
    'app_ar.arb': RegExp(r'علاجي|علاجية|سريري|سريرية|السجل الطبي|حرق الدهون|رحلتك'),
    'app_en.arb': RegExp(
        r'therapeutic|clinical (nutrition|dietitian|care)|burn fat|certified record',
        caseSensitive: false),
  };
  for (final entry in banned.entries) {
    test('${entry.key} makes no medical claims', () {
      final strings =
          jsonDecode(File('lib/l10n/${entry.key}').readAsStringSync())
              as Map<String, dynamic>;
      final hits = [
        for (final e in strings.entries)
          if (!e.key.startsWith('@') &&
              e.value is String &&
              entry.value.hasMatch(e.value as String))
            e.key,
      ];
      expect(hits, isEmpty);
    });
  }
}
