// Small fixes after the redesign: the meal detail's calories and macros, the
// weekly plan's header and day title, a few words, and the crash-test switch.
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/config/feature_flags.dart';
import 'package:healthylife_ai/core/logging/crash_reporter.dart';
import 'package:healthylife_ai/core/logging/crash_test.dart';
import 'package:healthylife_ai/l10n/l10n.dart';
import 'package:healthylife_ai/presentation/screens/about_app_screen.dart';
import 'package:healthylife_ai/presentation/screens/meal_detail_screen.dart';
import 'package:healthylife_ai/presentation/screens/weekly_plan_screen.dart';

import '../helpers/app_font.dart';
import '../helpers/sample_meal_plan.dart';
import '../helpers/screen_fixtures.dart';

final _ar = lookupAppLocalizations(const Locale('ar'));

Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 6));
}

/// The text of the macro box labelled [label].
String _macro(WidgetTester tester, String label) {
  final box = find.ancestor(
      of: find.text(label), matching: find.byType(Column)).first;
  final texts = tester
      .widgetList<Text>(find.descendant(of: box, matching: find.byType(Text)))
      .map((t) => t.data)
      .whereType<String>()
      .where((t) => t != label);
  return texts.single;
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    expect(await loadAppFont(), isTrue);
    await loadMaterialIcons();
  });

  group('meal detail', () {
    testWidgets('says "meal calories" and names the macros like the app',
        (tester) async {
      await pumpScreen(tester, const Size(412, 1600),
          (_) => MealDetailScreen(meal: sampleLunch()));
      expect(find.text('سعرات الوجبة'), findsOneWidget);
      expect(find.text('إجمالي السعرات النشطة'), findsNothing);
      expect(find.text('الكربوهيدرات'), findsOneWidget);
      expect(find.text('الدهون'), findsOneWidget);
      expect(find.text('الكارب'), findsNothing);
      expect(find.text('الدهون الصحية'), findsNothing);
      await _unmount(tester);
    });

    testWidgets('the macros are the plan meal\'s, not fixed numbers',
        (tester) async {
      await pumpScreen(tester, const Size(412, 1600),
          (_) => MealDetailScreen(meal: sampleLunch()));
      // Lunch in the plan: protein 50, carbs 36, fat 7.
      expect(_macro(tester, _ar.macroProtein), '50 غ');
      expect(_macro(tester, _ar.macroCarbs), '36 غ');
      expect(_macro(tester, _ar.macroHealthyFats), '7 غ');

      // Fish (38 g protein, 3 g fat) in place of chicken (45, 6).
      await tester.tap(find.text('سمك فيليه'));
      // The numbers count to their new value.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      expect(_macro(tester, _ar.macroProtein), '43 غ');
      expect(_macro(tester, _ar.macroHealthyFats), '4 غ');
      await _unmount(tester);
    });

    testWidgets('the ingredients title is not cut at 360px', (tester) async {
      await pumpScreen(tester, const Size(360, 1600),
          (_) => MealDetailScreen(meal: sampleLunch()));
      final title = tester.widget<Text>(find.text(_ar.mealDetailIngredients));
      expect(title.overflow, isNot(TextOverflow.ellipsis));
      final paragraph = tester.renderObject<RenderParagraph>(
          find.text(_ar.mealDetailIngredients));
      expect(paragraph.didExceedMaxLines, isFalse);
      await _unmount(tester);
    });
  });

  group('weekly plan', () {
    testWidgets('a plain header, a full day title and "سعرة" on the days',
        (tester) async {
      await pumpScreen(tester, const Size(360, 1600),
          (_) => const WeeklyPlanScreen());
      expect(find.text('الخطة الأسبوعية'), findsOneWidget);
      expect(find.textContaining('شاشة استعراض'), findsNothing);
      expect(find.textContaining(' سعرة'), findsWidgets);
      expect(find.textContaining(RegExp(r'^\d+ س$')), findsNothing);
      final day = find.textContaining('خطة يوم');
      expect(tester.widget<Text>(day).overflow, isNot(TextOverflow.ellipsis));
      expect(tester.renderObject<RenderParagraph>(day).didExceedMaxLines,
          isFalse);
      expect(tester.takeException(), isNull);
      await _unmount(tester);
    });
  });

  test('"upcoming appointments" is Modern Standard Arabic', () {
    expect(_ar.callsLaterTitle, 'المواعيد القادمة');
  });

  group('crash test', () {
    test('is off unless the build turns it on', () {
      expect(FeatureFlags.crashTest, isFalse);
    });

    testWidgets('About has no test-crash row in a normal build',
        (tester) async {
      await pumpScreen(tester, const Size(412, 2400),
          (_) => const AboutAppScreen());
      expect(find.text(_ar.aboutCrashTestTitle), findsNothing);
      await _unmount(tester);
    });

    test('the test crash is uncaught and reported by its type', () async {
      Object? caught;
      await runZonedGuarded(() async {
        triggerTestCrash(after: Duration.zero);
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }, (error, _) => caught = error);
      expect(caught, isA<CrashTestError>());
      expect(RedactedError.of(caught!).type, 'CrashTestError');
    });

    test('only the internal-test APK in CI sets CRASH_TEST', () {
      final lines = File('.github/workflows/flutter-checks.yml')
          .readAsLinesSync()
          .where((l) => l.contains('--dart-define=CRASH_TEST=true'))
          .toList();
      expect(lines, hasLength(1));
      expect(lines.single.trim(),
          'run: flutter build apk --release --dart-define=CRASH_TEST=true');
    });
  });
}
