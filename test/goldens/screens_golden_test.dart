// Screenshots of the main screens, in Arabic with the app's Cairo font, at
// 360x800 and 412x915. They are the before/after pictures of a UI change:
// regenerate them in the pull request that changes a screen, and the image
// diff shows what changed.
//
//   flutter test --run-skipped --tags golden --update-goldens test/goldens
//
// The screens show today's date, so the pictures are not compared in a normal
// test run (see the `golden` tag in dart_test.yaml).
@Tags(['golden'])
library;


import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/di/app_dependencies.dart';
import 'package:healthylife_ai/domain/entities/meal_entities.dart';
import 'package:healthylife_ai/presentation/app_shell.dart';
import 'package:healthylife_ai/presentation/screens/food_search_screen.dart';
import 'package:healthylife_ai/presentation/screens/login_screen.dart';
import 'package:healthylife_ai/presentation/screens/measurements_screen.dart';
import 'package:healthylife_ai/presentation/screens/new_measurement_screen.dart';
import 'package:healthylife_ai/presentation/screens/notifications_center_screen.dart';
import 'package:healthylife_ai/presentation/screens/onboarding_health_screen.dart';
import 'package:healthylife_ai/presentation/screens/quantity_selector_screen.dart';
import 'package:healthylife_ai/presentation/screens/quick_request_screen.dart';
import 'package:healthylife_ai/presentation/screens/schedule_calls_screen.dart';
import 'package:healthylife_ai/presentation/screens/weekly_plan_screen.dart';
import 'package:healthylife_ai/presentation/screens/health_record_screen.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/presentation/widgets/app_header_bar.dart';
import 'package:healthylife_ai/presentation/widgets/load_error_view.dart';
import 'package:healthylife_ai/presentation/widgets/state_views.dart';

import '../helpers/app_font.dart';
import '../helpers/screen_fixtures.dart';

Future<void> _shot(
  WidgetTester tester,
  String name,
  Size size,
  Widget Function(AppDependencies deps) screen, {
  Future<void> Function(WidgetTester tester)? act,
  bool signedIn = true,
  Map<String, Object?> Function(Map<String, Object?>)? routes,
}) async {
  final key = await pumpScreen(tester, size, screen,
      act: act, signedIn: signedIn, routes: routes);
  final tag = '${size.width.toInt()}x${size.height.toInt()}';
  await expectLater(
      find.byKey(key), matchesGoldenFile('screens/${name}_$tag.png'));
  // Unmount so timers are disposed.
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 6));
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    expect(await loadAppFont(), isTrue);
    await loadMaterialIcons();
  });

  for (final size in const [Size(360, 800), Size(412, 915)]) {
    final t = '${size.width.toInt()}';
    testWidgets(
        'login $t',
        (tester) => _shot(tester, '01_login', size, (_) => const LoginScreen(),
            signedIn: false));
    testWidgets('home $t',
        (tester) => _shot(tester, '02_home', size, (_) => const AppShell()));
    testWidgets(
        'today plan $t',
        (tester) =>
            _shot(tester, '03_today_plan', size, (_) => const AppShell(),
                act: (tester) async {
              await tester.tap(find.byIcon(Icons.event_note_rounded).first,
                  warnIfMissed: false);
            }));
    testWidgets(
        'weekly plan $t',
        (tester) => _shot(
            tester, '04_weekly_plan', size, (_) => const WeeklyPlanScreen()));
    testWidgets(
        'log meal sheet $t',
        (tester) => _shot(tester, '05_log_meal_sheet', size,
            (_) => const AppShell(), act: (tester) async {
          // The + button of the shell opens the sheet over Home.
          await tester.tap(find.byIcon(Icons.add_rounded).first);
        }));
    testWidgets(
        'meal detail $t',
        (tester) =>
            _shot(tester, '06_home_meals', size, (_) => const AppShell(),
                act: (tester) async {
              await tester.ensureVisible(find.text('الفطور').last);
              await tester.pump(const Duration(milliseconds: 300));
              await tester.tap(find.text('الفطور').last, warnIfMissed: false);
            }));
    testWidgets(
        'food search $t',
        (tester) => _shot(
                tester, '07_food_search', size, (_) => const FoodSearchScreen(),
                act: (tester) async {
              await tester.enterText(find.byType(TextField).first, 'دجاج');
              await tester.pump(const Duration(milliseconds: 600));
            }));
    testWidgets(
        'quantity $t',
        (tester) => _shot(
            tester,
            '08_quantity',
            size,
            (_) => const QuantitySelectorScreen(
                food: SearchableFood(
                    id: 7,
                    name: 'صدر دجاج مشوي',
                    caloriesPer100g: 165,
                    macro: 'protein'))));
    testWidgets(
        'progress $t',
        (tester) => _shot(tester, '09_progress', size, (_) => const AppShell(),
                act: (tester) async {
              await tester.tap(find.byIcon(Icons.insights_rounded).first,
                  warnIfMissed: false);
            }));
    testWidgets(
        'measurements $t',
        (tester) => _shot(tester, '10_measurements', size,
            (_) => const MeasurementsScreen()));
    testWidgets(
        'new measurement $t',
        (tester) => _shot(tester, '11_new_measurement', size,
            (_) => const MeasurementEntryScreen()));
    testWidgets(
        'profile $t',
        (tester) => _shot(tester, '12_profile', size, (_) => const AppShell(),
                act: (tester) async {
              await tester.tap(find.byIcon(Icons.person_rounded).first,
                  warnIfMissed: false);
            }));
    testWidgets(
        'notifications $t',
        (tester) => _shot(tester, '13_notifications', size,
            (_) => const NotificationsCenterScreen()));
    testWidgets(
        'appointments $t',
        (tester) => _shot(tester, '14_appointments', size,
            (_) => const ScheduleCallsScreen()));
    testWidgets(
        'quick request $t',
        (tester) => _shot(tester, '15_quick_request', size,
            (_) => const QuickRequestScreen()));
    testWidgets(
        'onboarding health $t',
        (tester) => _shot(tester, '16_onboarding_health', size,
            (_) => const OnboardingHealthScreen()));
    testWidgets(
        'health record $t',
        (tester) => _shot(tester, '17_health_record', size,
            (_) => const HealthRecordScreen()));
    testWidgets(
        'state loading $t',
        (tester) => _shot(
            tester,
            '18_state_loading',
            size,
            (_) => const Scaffold(
                appBar: AppHeaderBar(title: 'الإشعارات'), body: ListSkeleton()),
            signedIn: false));
    testWidgets(
        'state offline $t',
        (tester) => _shot(
            tester,
            '19_state_offline',
            size,
            (_) => Scaffold(
                appBar: const AppHeaderBar(title: 'الإشعارات'),
                body: LoadErrorView(
                    failure: const NetworkFailure(), onRetry: () {})),
            signedIn: false));
    testWidgets(
        'state empty $t',
        (tester) => _shot(
            tester,
            '20_state_empty',
            size,
            (_) => const Scaffold(
                appBar: AppHeaderBar(title: 'طلباتي'),
                body: EmptyState(
                    title: 'لا توجد طلبات',
                    message: 'ستظهر هنا طلباتك وردود أخصائيك.',
                    icon: Icons.mark_email_unread_outlined,
                    actionLabel: 'طلب جديد',
                    onAction: _noop)),
            signedIn: false));
  }
}

void _noop() {}
