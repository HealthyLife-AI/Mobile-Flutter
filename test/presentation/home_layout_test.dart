// The redesigned home: the day card first, then today's meals with the next
// one highlighted, then the questionnaire and the other cards. Everything the
// old home offered is still reachable.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/presentation/screens/home_dashboard_screen.dart';
import 'package:healthylife_ai/presentation/screens/weekly_plan_screen.dart';
import 'package:healthylife_ai/presentation/widgets/home_day.dart';
import 'package:healthylife_ai/presentation/widgets/log_meal_sheet.dart';
import 'package:healthylife_ai/presentation/widgets/quick_contact_card.dart';
import 'package:healthylife_ai/presentation/widgets/today_card.dart';

import '../helpers/app_font.dart';
import '../helpers/screen_fixtures.dart';

const _tall = Size(412, 2600);

Future<void> _home(WidgetTester tester) => pumpScreen(
    tester, _tall, (_) => const HomeDashboardScreen(),
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

  testWidgets('the day card comes first, then the meals, then the reminders',
      (tester) async {
    await _home(tester);
    final card = tester.getRect(find.byType(HomeDayCard));
    final firstMeal = tester.getRect(find.byType(HomeMealTile).first);
    final reminders = tester.getRect(find.byType(TodayReminders));
    expect(card.bottom, lessThan(firstMeal.top));
    expect(firstMeal.bottom, lessThan(reminders.top),
        reason: 'the questionnaire sits below the meals');
    // "يومك اليوم" is folded into the day card, not a card of its own.
    expect(find.text("Today's day"), findsNothing);
    await _unmount(tester);
  });

  testWidgets('only the next meal has the two actions', (tester) async {
    await _home(tester);
    expect(find.text('I ate it'), findsOneWidget);
    expect(find.text('Details & swaps'), findsOneWidget);
    expect(find.text('Next meal'), findsOneWidget);
    final next = find.ancestor(
        of: find.text('I ate it'), matching: find.byType(HomeMealTile));
    expect(
        find.descendant(of: next, matching: find.text('Next meal')),
        findsOneWidget);
    // The other meals each have a single "Log" button.
    expect(find.text('Log'), findsNWidgets(3));
    await _unmount(tester);
  });

  testWidgets('the weekly plan is one tap away', (tester) async {
    await _home(tester);
    await tester.tap(find.text('Weekly plan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(WeeklyPlanScreen), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('off-plan opens the log sheet', (tester) async {
    await _home(tester);
    await tester.tap(find.text('Ate something off plan?'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(LogMealSheet), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('quick contact and the bell are still there', (tester) async {
    await _home(tester);
    expect(find.byType(QuickContactCard), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none_rounded), findsWidgets);
    await _unmount(tester);
  });

  for (final locale in const [Locale('ar'), Locale('en')]) {
    for (final scale in const [1.0, 1.3]) {
      testWidgets('home fits 360dp (${locale.languageCode} x$scale)',
          (tester) async {
        await pumpScreen(
            tester, const Size(360, 800), (_) => const HomeDashboardScreen(),
            locale: locale, textScale: scale);
        expect(tester.takeException(), isNull);
        await _unmount(tester);
      });
    }
  }
}
