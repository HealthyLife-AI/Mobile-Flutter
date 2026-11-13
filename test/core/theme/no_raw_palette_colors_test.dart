import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The brand's teal, mint, green, red, slate and tint shades come from
/// `AppColors`. These raw values used to be repeated, slightly different, in
/// 25 screens; none may come back. Colours with no token (the WhatsApp green,
/// the gold of a star or a medal) are not listed.
void main() {
  const raw = [
    '0E7C86', '0E6F78', '00636E', '6FF0CF', '5EE0B0', '7DF2D6', '3DDBB0', //
    '7FE3C9', '19D3A2', '12A37F', '34D3A5', '12B886', '1E9E6F', '1E9E6A',
    '1FB57A', '16A34A', '0B4F44', 'E5484D', 'EF4444', 'DC2626', 'EF5B5B',
    'FF5A6E', 'B3261E', '1F2A44', '16303A', '3E5A8C', '7A8197', '475467',
    '8795A0', '4B5F69', '6B8C90', '173B36', '0284C7', 'EA580C', 'FFEDD5',
    '7C3AED', 'ECEAFA', '5B52B0', 'E3F8F0', 'BDEFDC', 'D5F5E9', 'C9F3E3',
    'D3F3E8', 'D8F5EA', 'E0F6EC', 'D5F7EA', 'D6F5E9', 'E6F8F0', 'D3F0E6',
    'D2F4E6', 'D9F5EC', 'B8F0DF', 'DCEFEA', 'EAF7F2', 'F1FAF7', 'EFF8F5',
    'F2FBF9', 'F7FBFA', 'F3F5F6', 'F1F4F5', 'E0ECEF', 'D9E8EA', 'E6EBED',
    'E3F5F7', 'D6EEFA', 'BFD6D4', 'B9C6C8', 'A8CFD0', 'A6CCC6', 'B6D4D6',
    'B3D0D4', 'A7C4BC', 'D9DBF2', 'FDF3E4', 'FFF1DC', 'F2C265', 'F6D3A6',
    'D9822B', 'C98A1F', 'B45309', 'FCE4E4', 'FDE8E8', 'FFDCD8', 'FFE3E3',
  ];

  test('no raw palette shade outside the theme', () {
    final found = <String>[];
    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) =>
            f.path.endsWith('.dart') &&
            !f.path.contains('core/theme') &&
            !f.path.contains('l10n/generated'))) {
      final text = file.readAsStringSync();
      for (final hex in raw) {
        if (RegExp('0xFF$hex', caseSensitive: false).hasMatch(text)) {
          found.add('${file.path}: $hex');
        }
      }
    }
    expect(found, isEmpty);
  });
}
