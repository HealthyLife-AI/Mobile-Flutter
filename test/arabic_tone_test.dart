import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The Arabic is simplified Modern Standard Arabic, and it does not assume the
/// patient's gender: the specialist is «أخصائي التغذية», and buttons use
/// the masculine generic only where a verb is unavoidable.
void main() {
  final strings = jsonDecode(File('lib/l10n/app_ar.arb').readAsStringSync())
      as Map<String, dynamic>;

  List<String> hits(RegExp pattern) => [
        for (final e in strings.entries)
          if (!e.key.startsWith('@') &&
              e.value is String &&
              pattern.hasMatch(e.value as String))
            e.key,
      ];

  test('no dialect words', () {
    expect(
        hits(RegExp(
            r'(^|\s)(شو|إيش|ايش|هون|إلك|لسا|بدك|بترد|بتقدر|بيوصل|عشان|منيح|مش|هالـ|احكي)(\s|$|،|؟)')),
        isEmpty);
  });

  test('no feminine address and no feminine specialist', () {
    expect(
        hits(RegExp(
            r'أخصائيتك|جرّبي|اطلبي|أضيفي|اختاري|سجّلي|اجعلي|سجّلتِ|خطتكِ')),
        isEmpty);
  });

  // Dialect the first pass missed: «هالجهاز», «هالأسبوع», «ورا بعض»,
  // «ما قدرنا», «شغل».
  test('no dialect demonstratives or phrasing', () {
    expect(
        hits(RegExp(r'(^|\s)هال\S|ورا بعض|ما قدرنا|(^|\s)شغل(\s|$)')), isEmpty);
  });
}
