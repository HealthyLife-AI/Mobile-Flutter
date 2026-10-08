import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:healthylife_ai/app_shell.dart';
import 'package:healthylife_ai/core/theme/app_colors.dart';
import 'package:healthylife_ai/core/theme/app_radius.dart';
import 'package:healthylife_ai/core/theme/app_text_styles.dart';
import 'package:healthylife_ai/models/meal_models.dart';
import 'package:healthylife_ai/screens/about_app_screen.dart';
import 'package:healthylife_ai/screens/daily_log_screen.dart';
import 'package:healthylife_ai/screens/health_data_consent_screen.dart';
import 'package:healthylife_ai/screens/language_settings_screen.dart';
import 'package:healthylife_ai/screens/meal_detail_screen.dart';
import 'package:healthylife_ai/screens/meal_log_success_screen.dart';
import 'package:healthylife_ai/screens/notification_settings_screen.dart';
import 'package:healthylife_ai/screens/onboarding_screen.dart';
import 'package:healthylife_ai/screens/onboarding_health_screen.dart';
import 'package:healthylife_ai/screens/onboarding_notifications_screen.dart';
import 'package:healthylife_ai/screens/onboarding_measurements_screen.dart';
import 'package:healthylife_ai/screens/password_settings_screen.dart';
import 'package:healthylife_ai/screens/plan_preparing_screen.dart';
import 'package:healthylife_ai/screens/profile_screen.dart';
import 'package:healthylife_ai/screens/quantity_selector_screen.dart';
import 'package:healthylife_ai/screens/specialist_profile_screen.dart';
import 'package:healthylife_ai/screens/splash_screen.dart';

/// Guards the Soft Light refactor against the three regressions it introduced:
///
///  1. a `RenderFlex` overflow on the smallest supported phone,
///  2. a CTA that drifts inside the scrollable or off-screen, and
///  3. an Arabic string that is no longer flush against the start (right) edge.
///
/// Font note: `pubspec.yaml` bundles no Arabic font, so `AppTextStyles
/// .fontFamily` ("Tajawal") resolves to the platform font at runtime. Widget
/// tests would otherwise fall back to the Ahem test font, where every glyph is
/// a full em wide — that inflates every string by roughly 2x and buries the
/// test in false positives. We load Segoe UI (full Arabic coverage, realistic
/// advance widths) under the family name the app actually asks for so the
/// layout maths matches the device.
late bool _realFontLoaded;

Future<bool> _loadSegoeAsTajawal() async {
  try {
    final regular = File(r'C:\Windows\Fonts\segoeui.ttf');
    if (!regular.existsSync()) return false;
    final loader = FontLoader(AppTextStyles.fontFamily);
    for (final path in [
      r'C:\Windows\Fonts\segoeui.ttf',
      r'C:\Windows\Fonts\segoeuib.ttf'
    ]) {
      final file = File(path);
      if (!file.existsSync()) continue;
      loader.addFont(
        file
            .readAsBytes()
            .then((bytes) => ByteData.view(Uint8List.fromList(bytes).buffer)),
      );
    }
    await loader.load();
    return true;
  } catch (_) {
    return false;
  }
}

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
Future<List<String>> _layoutErrors(
    WidgetTester tester, Widget child, Size size) async {
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
      Directionality(
        textDirection: TextDirection.rtl,
        child: MediaQuery(
          data: MediaQueryData(
              size: size, textScaler: const TextScaler.linear(1.0)),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                useMaterial3: true, colorSchemeSeed: AppColors.primary),
            builder: (context, appChild) => Directionality(
              textDirection: TextDirection.rtl,
              child: appChild ?? const SizedBox.shrink(),
            ),
            home: child,
          ),
        ),
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
    _realFontLoaded = await _loadSegoeAsTajawal();
    expect(_realFontLoaded, isTrue,
        reason: 'Segoe UI is required for realistic Arabic metrics');
  });

  testWidgets('plan tab opens daily log and calendar opens weekly plan',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink()),
        home: const AppShell(),
      ),
    );
    await tester.tap(find.byIcon(Icons.event_note_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('سجل اليوم'), findsOneWidget);

    await tester.tap(find.byTooltip('استعراض الخطة الأسبوعية'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('استعراض الخطة الأسبوعية'), findsOneWidget);
    expect(find.text('الأسبوع الثالث'), findsOneWidget);
  });

  testWidgets('splash shows the full logo and advances after three seconds',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump(const Duration(milliseconds: 2900));

    expect(
        find.image(const AssetImage('assets/images/logo.png')), findsOneWidget);
    expect(find.byType(ScaleTransition), findsAtLeastNWidgets(2));
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets('notification completion opens plan preparation', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink()),
        home: const OnboardingNotificationsScreen(),
      ),
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
      expect(tester.widget<Text>(heading.first).textAlign, TextAlign.right,
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
      expect(tester.widget<Text>(medication.first).textAlign, TextAlign.right,
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
    final errors = await _layoutErrors(
        tester, const QuantitySelectorScreen(food: food), _tablet);
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
    expect(MealLogStore.instance.entries.last.name, food.name);
    expect(MealLogStore.instance.entries.last.isOffPlan, isTrue);
    expect(MealLogStore.instance.entries.last.grams, 150);
  });

  group('overflow-free at every supported size', () {
    final screens = <String, Widget Function()>{
      'marketing onboarding': () => const OnboardingScreen(),
      'splash': () => const SplashScreen(),
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

/// The lunch entry `MockData.lunchDetailGroups` is authored against.
final Meal _lunch = MockData.todayMeals.firstWhere((m) => m.id == 'lunch');
