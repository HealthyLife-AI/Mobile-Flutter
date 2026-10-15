import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:healthylife_ai/l10n/l10n.dart';

/// A bare [MaterialApp] wired with the app's localizations, for mounting a
/// single screen or widget. Arabic — the app default — unless [locale] says
/// otherwise; text direction then comes from the locale, as in the app.
MaterialApp localizedApp({
  required Widget home,
  Locale locale = const Locale('ar'),
  ThemeData? theme,
  bool debugShowCheckedModeBanner = true,
}) =>
    MaterialApp(
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      theme: theme,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: home,
    );

/// Asserts that the laid-out glyphs of the [Text] found by [text] hug the
/// start edge of their box: the right edge in RTL, the left edge in LTR.
/// Checks where the text actually renders rather than which `TextAlign`
/// constant the code happened to use.
void expectTextHugsStartEdge(WidgetTester tester, Finder text,
    {required TextDirection direction, String? reason}) {
  final paragraph = tester.renderObject<RenderParagraph>(
      find.descendant(of: text.first, matching: find.byType(RichText)).first);
  expect(paragraph.textDirection, direction, reason: reason);
  final length = paragraph.text.toPlainText().length;
  final boxes = paragraph
      .getBoxesForSelection(TextSelection(baseOffset: 0, extentOffset: length));
  expect(boxes, isNotEmpty, reason: reason);
  if (direction == TextDirection.rtl) {
    final right = boxes.map((b) => b.right).reduce(math.max);
    expect(right, closeTo(paragraph.size.width, 1.0), reason: reason);
  } else {
    final left = boxes.map((b) => b.left).reduce(math.min);
    expect(left, closeTo(0, 1.0), reason: reason);
  }
}
