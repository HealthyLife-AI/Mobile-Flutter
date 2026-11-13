// The progress and measurements screens must fit a 360dp phone with a large
// system font, in both languages, and the weight chart's time must run left to
// right in both, as on the web dashboard.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/presentation/app_shell.dart';
import 'package:healthylife_ai/presentation/screens/measurements_screen.dart';
import 'package:healthylife_ai/presentation/screens/new_measurement_screen.dart';

import '../helpers/app_font.dart';
import '../helpers/screen_fixtures.dart';

const _phone = Size(360, 800);

Future<void> _openProgress(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.insights_rounded).first,
      warnIfMissed: false);
}

Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 6));
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    expect(await loadAppFont(), isTrue);
    await loadMaterialIcons();
  });

  for (final locale in const [Locale('ar'), Locale('en')]) {
    for (final scale in const [1.0, 1.3]) {
      final at = '${locale.languageCode} x$scale';
      testWidgets('progress fits $at', (tester) async {
        await pumpScreen(tester, _phone, (_) => const AppShell(),
            locale: locale, textScale: scale, act: _openProgress);
        expect(tester.takeException(), isNull);
        await _unmount(tester);
      });
      testWidgets('measurements fit $at', (tester) async {
        await pumpScreen(tester, _phone, (_) => const MeasurementsScreen(),
            locale: locale, textScale: scale);
        expect(tester.takeException(), isNull);
        await _unmount(tester);
      });
      testWidgets('a new measurement fits $at', (tester) async {
        await pumpScreen(tester, _phone, (_) => const MeasurementEntryScreen(),
            locale: locale, textScale: scale);
        expect(tester.takeException(), isNull);
        await _unmount(tester);
      });
    }
  }

  for (final entry in const {'ar': 'اليوم', 'en': 'Today'}.entries) {
    testWidgets('the chart axis ends on today at the right (${entry.key})',
        (tester) async {
      await pumpScreen(tester, _phone, (_) => const AppShell(),
          locale: Locale(entry.key), act: _openProgress);
      final today = find.text(entry.value);
      // Several screens say "today"; the axis one is the lowest on the page.
      final lowest = tester
          .widgetList<Text>(today)
          .map((w) => tester.getTopRight(find.byWidget(w)))
          .reduce((a, b) => a.dy > b.dy ? a : b);
      expect(lowest.dx, greaterThan(_phone.width * 0.6),
          reason: 'today is the right end of the time axis');
      await _unmount(tester);
    });
  }
}
