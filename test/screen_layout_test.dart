import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthylife_ai/core/di/app_dependencies.dart';
import 'package:healthylife_ai/main.dart';
import 'package:healthylife_ai/presentation/app_shell.dart';
import 'package:healthylife_ai/core/theme/app_colors.dart';
import 'package:healthylife_ai/core/theme/app_radius.dart';
import 'package:healthylife_ai/core/theme/app_theme.dart';
import 'package:healthylife_ai/presentation/screens/weekly_plan_screen.dart';
import 'package:healthylife_ai/presentation/bloc/meal_log/meal_log_cubit.dart';
import 'package:healthylife_ai/domain/entities/meal_entities.dart';
import 'package:healthylife_ai/domain/entities/measurement_entities.dart';
import 'package:healthylife_ai/presentation/screens/first_measurement_screen.dart';
import 'package:healthylife_ai/presentation/screens/about_app_screen.dart';
import 'package:healthylife_ai/presentation/screens/daily_log_screen.dart';
import 'package:healthylife_ai/presentation/screens/health_data_consent_screen.dart';
import 'package:healthylife_ai/presentation/screens/language_settings_screen.dart';
import 'package:healthylife_ai/presentation/screens/login_screen.dart';
import 'package:healthylife_ai/presentation/screens/meal_detail_screen.dart';
import 'package:healthylife_ai/presentation/screens/meal_log_success_screen.dart';
import 'package:healthylife_ai/presentation/screens/notification_settings_screen.dart';
import 'package:healthylife_ai/presentation/screens/onboarding_screen.dart';
import 'package:healthylife_ai/presentation/screens/onboarding_health_screen.dart';
import 'package:healthylife_ai/presentation/screens/onboarding_notifications_screen.dart';
import 'package:healthylife_ai/presentation/screens/onboarding_measurements_screen.dart';
import 'package:healthylife_ai/presentation/screens/password_settings_screen.dart';
import 'package:healthylife_ai/presentation/screens/plan_preparing_screen.dart';
import 'package:healthylife_ai/presentation/screens/profile_screen.dart';
import 'package:healthylife_ai/presentation/screens/quantity_selector_screen.dart';
import 'package:healthylife_ai/presentation/screens/specialist_profile_screen.dart';
import 'package:healthylife_ai/presentation/screens/splash_screen.dart';

import 'helpers/app_font.dart';
import 'helpers/app_providers.dart';
import 'helpers/localized_app.dart';
import 'helpers/sample_meal_plan.dart';

/// Guards the Soft Light refactor against the three regressions it introduced:
///
///  1. a `RenderFlex` overflow on the smallest supported phone,
///  2. a CTA that drifts inside the scrollable or off-screen, and
///  3. an Arabic string that is no longer flush against the start (right) edge.
///
/// Screens mount under the app's real localizations in Arabic, so RTL comes
/// from the locale exactly as in the running app — no forced Directionality.
///
/// Font note: the app's own font is loaded (see [loadAppFont]), so the
/// layout maths matches the device.
late bool _realFontLoaded;

/// The narrowest phone still supported, and a tablet-ish width to prove the
/// layouts stretch instead of clipping.
const Size _sePhone = Size(320, 568); // iPhone 5/SE-class worst case
const Size _sePhoneTall = Size(320, 667); // the size the brief called out
const Size _tablet = Size(834, 1112);

/// Pump [child] at [size] and return every layout error Flutter raised.
///
/// An uncaught overflow is a test failure, but several overflow warnings are
/// emitted through the reporter rather than thrown, so they are collected
/// explicitly instead of relying on the default behaviour.
Future<List<String>> _layoutErrors(WidgetTester tester, Widget child, Size size,
    {double textScale = 1.0}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  final errors = <String>[];
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    final extra = details.informationCollector?.call().join('\n') ?? '';
    errors.add('${details.exceptionAsString()}\n$extra');
  };
  try {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
            size: size, textScaler: TextScaler.linear(textScale)),
        // The app's own theme, so text that inherits its family measures in
        // the font loaded above, as on the device.
        child: appProviders(child, theme: AppTheme.light),
      ),
    );
    // Let entrance animations settle so lazily-built content is measured too.
    // The longest sequence in the app (notifications onboarding) runs 2s.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    return errors;
  } finally {
    FlutterError.onError = previousOnError;
  }
}

bool _isOverflow(List<String> errors) =>
    errors.any((e) => e.contains('overflowed'));

/// Fails with the layout error itself in the message, so a regression points
/// at the offending widget instead of just "expected empty".
void expectNoLayoutErrors(String label, List<String> errors) {
  if (errors.isEmpty) return;
  final overflow = _isOverflow(errors);
  fail(
    '$label ${overflow ? 'OVERFLOWED' : 'raised layout errors'}:\n'
    '${errors.map((e) => '  - $e').join('\n')}',
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    _realFontLoaded = await loadAppFont();
    expect(_realFontLoaded, isTrue,
        reason: 'Segoe UI is required for realistic Arabic metrics');
  });

  testWidgets('plan tab opens daily log and calendar opens weekly plan',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(appProviders(const AppShell()));
    await tester.tap(find.byIcon(Icons.event_note_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('سجل اليوم'), findsOneWidget);

    await tester.tap(find.byTooltip('استعراض الخطة الأسبوعية'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    // The weekly plan's title (the daily log beneath has a button with the
    // same words).
    expect(
        find.descendant(
            of: find.byType(WeeklyPlanScreen),
            matching: find.text('استعراض الخطة الأسبوعية')),
        findsOneWidget);
    // The nutritionist's plan, not demo content: its week (started two weeks
    // ago) and a food that only the plan contains.
    expect(find.text('الأسبوع ٣ من الخطة'), findsOneWidget);
    // Today's total from the plan's summary_by_day (993 kcal).
    expect(find.text('٩٩٣'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('صدر دجاج مشوي'), 300,
        scrollable: find
            .descendant(
                of: find.byType(WeeklyPlanScreen),
                matching: find.byType(Scrollable))
            .first);
    expect(find.text('صدر دجاج مشوي'), findsWidgets);
  });

  testWidgets('the button under "log a new meal" opens the weekly plan',
      (tester) async {
    await tester.pumpWidget(appProviders(const DailyLogScreen()));
    await tester.pump(const Duration(seconds: 2));

    final button = find.descendant(
        of: find.byType(DailyLogScreen),
        matching: find.text('استعراض الخطة الأسبوعية'));
    await tester.scrollUntilVisible(button, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(button);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(WeeklyPlanScreen), findsOneWidget);
  });

  testWidgets('splash shows the full logo and advances after three seconds',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    // Real app root: at the 3 s mark the splash reads the session through
    // the app-scoped AuthCubit (none is stored here, so sign-in opens).
    await tester.pumpWidget(const HealthyLifeApp(home: SplashScreen()));
    await tester.pump(const Duration(milliseconds: 2900));

    expect(
        find.image(const AssetImage('assets/images/logo.png')), findsOneWidget);
    expect(find.byType(ScaleTransition), findsAtLeastNWidgets(2));
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('notification completion opens plan preparation', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    // Real app root: finishing the wizard writes the session through the
    // app-scoped AuthCubit — this used to throw ProviderNotFoundException.
    await tester.pumpWidget(
      const HealthyLifeApp(home: OnboardingNotificationsScreen()),
    );
    // The CTA slides in on a 2s entrance; wait for it before tapping.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.byKey(const Key('onboarding-notifications-cta')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PlanPreparingScreen), findsOneWidget);
    expect(find.text('خطتكِ قيد التحضير بعناية'), findsOneWidget);
  });

  testWidgets('initial measurement headings are right aligned', (tester) async {
    final errors = await _layoutErrors(
        tester, const OnboardingMeasurementsScreen(), _sePhoneTall);
    expectNoLayoutErrors('initial measurements', errors);

    final scrollable = find.byType(Scrollable).first;
    for (final label in [
      'الوزن الحالي',
      'كيف آخذ قياساتي بشكل دقيق؟',
      'محيط الجسم'
    ]) {
      final heading = find.text(label);
      await tester.scrollUntilVisible(heading, 180, scrollable: scrollable);
      expectTextHugsStartEdge(tester, heading,
          direction: TextDirection.rtl,
          reason: '$label should be right-aligned');
    }
  });

  testWidgets('health medication names are right aligned', (tester) async {
    final errors = await _layoutErrors(
        tester, const OnboardingHealthScreen(), _sePhoneTall);
    expectNoLayoutErrors('health data', errors);

    final scrollable = find.byType(Scrollable).first;
    for (final name in ['متفورمين (Metformin) 500mg', 'فيتامين د 5000IU']) {
      final medication = find.text(name);
      await tester.scrollUntilVisible(medication, 180, scrollable: scrollable);
      expectTextHugsStartEdge(tester, medication,
          direction: TextDirection.rtl,
          reason: '$name should be right-aligned');
    }
  });

  testWidgets('account screen bottom remains within the viewport',
      (tester) async {
    final errors = await _layoutErrors(tester, const ProfileScreen(), _sePhone);
    expectNoLayoutErrors('profile screen', errors);

    final footer =
        find.text('يتطلب تأكيد تسجيل الخروج لضمان مزامنة قياساتك الأخيرة');
    await tester.scrollUntilVisible(footer, 240,
        scrollable: find.byType(Scrollable).first);
    expect(footer, findsOneWidget);
    expect(
        tester.getBottomRight(footer).dy, lessThanOrEqualTo(_sePhone.height));
  });

  testWidgets('health consent keeps its CTA visible outside the scroll area',
      (tester) async {
    final errors =
        await _layoutErrors(tester, const HealthDataConsentScreen(), _sePhone);
    expectNoLayoutErrors('health consent', errors);

    // The clauses are ~900px of content in a ~440px window, so the body
    // scrolls — but the CTA is a pinned footer, never part of the scrollable.
    expect(find.byType(Scrollable), findsWidgets);

    final cta = find.text('متابعة إعداد خطتي الصحية');
    expect(cta, findsOneWidget);
    expect(tester.getBottomRight(cta).dy, lessThanOrEqualTo(_sePhone.height));
    expect(
      find.ancestor(of: cta, matching: find.byType(Scrollable)),
      findsNothing,
      reason: 'the CTA must stay pinned while the clauses scroll',
    );
  });

  testWidgets('password settings matches the reference and toggles visibility',
      (tester) async {
    final errors = await _layoutErrors(
        tester, const PasswordSettingsScreen(), _sePhoneTall);
    expectNoLayoutErrors('password settings', errors);

    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(3));
    // All three fields start hidden.
    expect(tester.widget<TextField>(fields.at(0)).obscureText, isTrue);
    expect(tester.widget<TextField>(fields.at(1)).obscureText, isTrue);
    expect(tester.widget<TextField>(fields.at(2)).obscureText, isTrue);

    await tester.tap(find.byKey(const ValueKey('password-visibility-current')));
    await tester.pump();
    expect(tester.widget<TextField>(fields.at(0)).obscureText, isFalse);
    await tester.tap(find.byKey(const ValueKey('password-visibility-new')));
    await tester.pump();
    expect(tester.widget<TextField>(fields.at(1)).obscureText, isFalse);
    await tester.tap(find.byKey(const ValueKey('password-visibility-confirm')));
    await tester.pump();
    expect(tester.widget<TextField>(fields.at(2)).obscureText, isFalse);

    await tester.enterText(fields.at(0), 'CurrentPass1!');
    await tester.enterText(fields.at(1), 'StrongPass1!');
    await tester.enterText(fields.at(2), 'StrongPass1!');
    await tester.pump();
    expect(find.text('تطابق كلمة المرور الجديدة تماماً'), findsOneWidget);
    expect(find.text('قوية جداً'), findsOneWidget);
  });

  testWidgets('off-plan confirmation records food and shows its summary',
      (tester) async {
    const food = SearchableFood(
        name: 'زبادي مضاف', caloriesPer100g: 59, macro: 'protein');
    final deps = AppDependencies.inMemory();
    final errors = await _layoutErrors(
        tester,
        BlocProvider(
          create: (_) => MealLogCubit(deps.mealLog, deps.logMeal),
          child: const QuantitySelectorScreen(food: food),
        ),
        _tablet);
    expectNoLayoutErrors('quantity selector', errors);

    await tester.scrollUntilVisible(
      find.text('تأكيد الكمية وتسجيل الطعام'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('تأكيد الكمية وتسجيل الطعام'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(MealLogSuccessScreen), findsOneWidget);
    expect(find.text(food.name), findsWidgets);
    final entries = (await deps.mealLog.getEntries()).valueOrNull!;
    expect(entries.last.name, food.name);
    expect(entries.last.isOffPlan, isTrue);
    expect(entries.last.grams, 150);
  });

  group('overflow-free at every supported size', () {
    final screens = <String, Widget Function()>{
      'marketing onboarding': () => const OnboardingScreen(),
      // "splash" is not here: its 3 s status timer and repeating ambient
      // animation make it unfit for the generic pump harness. It has a
      // dedicated test above.
      'daily log': () => const DailyLogScreen(),
      'initial measurements': () => const OnboardingMeasurementsScreen(),
      'onboarding notifications': () => const OnboardingNotificationsScreen(),
      'profile': () => const ProfileScreen(),
      'notification settings': () => const NotificationSettingsScreen(),
      'meal details': () => MealDetailScreen(meal: _lunch),
      'about app': () => const AboutAppScreen(),
      'language settings': () => const LanguageSettingsScreen(),
      'specialist profile': () => const SpecialistProfileScreen(),
      'app shell': () => const AppShell(),
      'weekly plan': () => const WeeklyPlanScreen(),
      'measurement prompt, first': () => const FirstMeasurementScreen(
          showBack: false, showExitAction: false, replaceEntryRoute: false),
      'measurement prompt, second': () =>
          FirstMeasurementScreen(snapshot: _readings(1), onViewProgress: () {}),
      'measurement prompt, weekly': () =>
          FirstMeasurementScreen(snapshot: _readings(3), onViewProgress: () {}),
    };

    screens.forEach((name, builder) {
      for (final size in const [_sePhone, _sePhoneTall, _tablet]) {
        testWidgets('$name @ ${size.width.toInt()}x${size.height.toInt()}',
            (tester) async {
          final errors = await _layoutErrors(tester, builder(), size);
          expectNoLayoutErrors('$name @ $size', errors);
        });
      }
    });

    // A larger system font, as many phones are set: the day strip and the
    // daily log must still fit.
    final largeFont = <String, Widget Function()>{
      'weekly plan': () => const WeeklyPlanScreen(),
      'daily log': () => const DailyLogScreen(),
      'app shell': () => const AppShell(),
    };
    largeFont.forEach((name, builder) {
      for (final scale in const [1.15, 1.3]) {
        testWidgets('$name @ 360x780, font x$scale', (tester) async {
          final errors = await _layoutErrors(
              tester, builder(), const Size(360, 780),
              textScale: scale);
          expectNoLayoutErrors('$name @ font x$scale', errors);
        });
      }
    });

    // Shorter than the supported minimum: the hero clamp used to throw an
    // ArgumentError here (clamp(220, height - 340) with a negative upper bound).
    testWidgets('marketing onboarding @ 320x480 (short viewport)',
        (tester) async {
      final errors = await _layoutErrors(
          tester, const OnboardingScreen(), const Size(320, 480));
      expectNoLayoutErrors('marketing onboarding @ 320x480', errors);
    });
  });

  group('onboarding notifications keeps the CTA reachable', () {
    testWidgets('body has a scroll fallback for compact viewports',
        (tester) async {
      await _layoutErrors(
          tester, const OnboardingNotificationsScreen(), _sePhoneTall);

      final scrollables =
          tester.widgetList<Scrollable>(find.byType(Scrollable)).toList();
      expect(scrollables, isNotEmpty,
          reason: 'the compact-layout safety net should remain scrollable');
      expect(
          scrollables
              .any((scrollable) => scrollable.physics is ClampingScrollPhysics),
          isTrue);
    });

    testWidgets('the call to action is visible without scrolling',
        (tester) async {
      await _layoutErrors(
          tester, const OnboardingNotificationsScreen(), _sePhoneTall);

      final cta = find.byKey(const Key('onboarding-notifications-cta'));
      expect(cta, findsOneWidget);
      expect(tester.getTopLeft(cta).dy, greaterThanOrEqualTo(0));
      expect(tester.getBottomRight(cta).dy,
          lessThanOrEqualTo(_sePhoneTall.height));
    });
  });

  group('Arabic stays RTL and flush right', () {
    testWidgets('meal detail headings hug the start (right) edge',
        (tester) async {
      await _layoutErrors(tester, MealDetailScreen(meal: _lunch), _sePhone);

      for (final label in ['مكونات الوجبة والبدائل', 'مرونة الاستبدال الذكي']) {
        final finder = find.text(label);
        await tester.scrollUntilVisible(finder, 240,
            scrollable: find.byType(Scrollable).first);
        expect(finder, findsOneWidget, reason: 'missing "$label"');
        final right = tester.getTopRight(finder).dx;
        expect(
          right,
          greaterThan(_sePhone.width * 0.6),
          reason: '"$label" is left-anchored; Arabic must read from the right',
        );
      }
    });

    testWidgets('about / language / specialist screens render RTL',
        (tester) async {
      for (final builder in [
        () => const AboutAppScreen() as Widget,
        () => const LanguageSettingsScreen(),
        () => const SpecialistProfileScreen(),
        () => const ProfileScreen(),
      ]) {
        await _layoutErrors(tester, builder(), _sePhone);
        expect(
          Directionality.of(tester.element(find.byType(Navigator).first)),
          TextDirection.rtl,
        );
      }
    });
  });

  group('brand tokens', () {
    test('primary is the brief\'s #028090', () {
      expect(AppColors.primary, const Color(0xFF028090));
    });

    test('canvas is the soft-light #F8FAFC', () {
      expect(AppColors.background, const Color(0xFFF8FAFC));
      expect(AppColors.surface, Colors.white);
    });

    test('radius scale still resolves', () {
      expect(AppRadius.card, greaterThan(0));
    });
  });
}

/// Lunch from the sample plan: three items, two of them with an alternative.
final Meal _lunch = sampleLunch();

/// Readings for the measurement prompt: [count] weekly readings, the latest
/// on a long date (a Wednesday in September) to stress the date row.
MeasurementSnapshot _readings(int count) {
  final readings = [
    for (var i = 0; i < count; i++)
      MeasurementEntry(
          id: '$i',
          recordedAt: DateTime(2026, 9, 30 - 7 * (count - 1 - i)),
          weightKg: 104.5 - i),
  ];
  return MeasurementSnapshot(
    currentWeight: readings.last.weightKg,
    previousWeight: null,
    weightTrend: [
      for (final r in readings)
        WeightPoint(date: r.recordedAt, kg: r.weightKg!),
    ],
    circumference: const [],
    daysLoggedThisWeek: 0,
    daysLoggedThisMonth: 0,
    savedEntries: readings,
  );
}
