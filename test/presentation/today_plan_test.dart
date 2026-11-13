// The plan tab as "today's plan": a week strip, the day's calories and macros,
// and each meal with its foods, grams, swap hints and one log button.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/presentation/screens/daily_log_screen.dart';
import 'package:healthylife_ai/presentation/widgets/today_plan.dart';

import '../helpers/app_font.dart';
import '../helpers/screen_fixtures.dart';

const _tall = Size(412, 2600);

Future<void> _plan(WidgetTester tester) => pumpScreen(
    tester, _tall, (_) => const DailyLogScreen(),
    locale: const Locale('en'));

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

  testWidgets('the week strip has seven days with today selected',
      (tester) async {
    await _plan(tester);
    expect(find.byType(WeekStrip), findsOneWidget);
    final today = DateTime.now().day.toString();
    final selected = tester
        .widgetList<Semantics>(find.descendant(
            of: find.byType(WeekStrip), matching: find.byType(Semantics)))
        .where((s) => s.properties.selected == true)
        .toList();
    expect(selected, hasLength(1));
    expect(selected.single.properties.label, endsWith(' $today'));
    await _unmount(tester);
  });

  testWidgets("the day's calories and macros come from the plan",
      (tester) async {
    await _plan(tester);
    final totals = find.byType(DayTotalsCard);
    expect(find.descendant(of: totals, matching: find.text('993')),
        findsOneWidget);
    for (final label in ['Protein', 'Carbohydrates', 'Fat']) {
      expect(find.descendant(of: totals, matching: find.text(label)),
          findsOneWidget);
    }
    await _unmount(tester);
  });

  testWidgets('meals list their foods with grams, swaps and one log button',
      (tester) async {
    await _plan(tester);
    expect(find.byType(PlanMealCard), findsNWidgets(4));
    // Food names come from the plan as written by the nutritionist.
    expect(find.text('صدر دجاج مشوي'), findsWidgets);
    expect(find.text('Swap available'), findsWidgets);
    expect(find.text('I had this meal'), findsNWidgets(4));

    await tester.tap(find.text('I had this meal').first);
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(find.text('I had this meal'), findsNWidgets(3));
    expect(find.textContaining('Logged '), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('another day is shown but not loggable', (tester) async {
    await _plan(tester);
    final strip = find.byType(WeekStrip);
    final days = find.descendant(of: strip, matching: find.byType(InkWell));
    final todayIndex = (DateTime.now().weekday - DateTime.saturday) % 7;
    await tester.tap(days.at(todayIndex == 0 ? 1 : 0));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('I had this meal'), findsNothing);
    expect(find.text('Back to today'), findsOneWidget);
    await tester.tap(find.text('Back to today'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('I had this meal'), findsWidgets);
    await _unmount(tester);
  });

  for (final locale in const [Locale('ar'), Locale('en')]) {
    for (final scale in const [1.0, 1.3]) {
      testWidgets('the plan tab fits 360dp (${locale.languageCode} x$scale)',
          (tester) async {
        await pumpScreen(
            tester, const Size(360, 800), (_) => const DailyLogScreen(),
            locale: locale, textScale: scale);
        expect(tester.takeException(), isNull);
        await _unmount(tester);
      });
    }
  }
}
