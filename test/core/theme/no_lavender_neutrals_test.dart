import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The bluish-lavender greys the old design used for fills and borders are the
/// brand's teal-tinted neutrals now (`AppColors.panel`, `chipInactiveBg`,
/// `border`, `background`). A raw lavender grey in a screen drifts away from
/// the web dashboard's look, so none may come back.
void main() {
  const lavender = [
    'F2F4FC', 'EEF1FC', 'F6F8FE', 'F4F6FD', 'F3F6FC', 'F3F5FC', 'F5F7FD', //
    'EEF1FA', 'EEF2FD', 'F1F4FC', 'EEF1F8', 'EDF0F6', 'F6F7FC', 'F4F7FD',
    'F4F6FC', 'EEF1FB', 'EEF2FF', 'FBFCFE', 'EBEFF6', 'E9EFFA', 'E3EAFB',
    'E3ECFA', 'E6EBFA', 'E3E8EF', 'DDE3F3', 'DDE6F8', 'DCE5FA', 'DCE3F4',
    'DCE3EC', 'DDE2EC', 'D5DBEE',
  ];

  test('no lavender grey outside the theme', () {
    final found = <String>[];
    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) =>
            f.path.endsWith('.dart') &&
            !f.path.contains('core/theme') &&
            !f.path.contains('l10n/generated'))) {
      final text = file.readAsStringSync();
      for (final hex in lavender) {
        if (RegExp('0xFF$hex', caseSensitive: false).hasMatch(text)) {
          found.add('${file.path}: $hex');
        }
      }
    }
    expect(found, isEmpty);
  });
}
