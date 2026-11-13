// Every screen with two different data sets. A number or a name shown on a
// screen either comes from the data, and then it changes with the data, or it
// is real copy (a server limit, a unit, a step count), and then it is listed
// here on purpose. A value that looks like data but never moves, like the
// meal macros that were once written into the screen, fails this test.
//
// Data set B doubles every number of A (except ids and codes), adds a letter
// to every name and text, and signs in another patient.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/config/app_version.dart';
import 'package:healthylife_ai/data/models/meal_plan_dto.dart';
import 'package:healthylife_ai/domain/entities/auth_entities.dart';
import 'package:healthylife_ai/domain/entities/meal_entities.dart';
import 'package:healthylife_ai/l10n/l10n.dart';
import 'package:healthylife_ai/presentation/app_shell.dart';
import 'package:healthylife_ai/presentation/screens/about_app_screen.dart';
import 'package:healthylife_ai/presentation/screens/achievements_screen.dart';
import 'package:healthylife_ai/presentation/screens/book_appointment_screen.dart';
import 'package:healthylife_ai/presentation/screens/checkin_screen.dart';
import 'package:healthylife_ai/presentation/screens/food_preferences_screen.dart';
import 'package:healthylife_ai/presentation/screens/food_search_screen.dart';
import 'package:healthylife_ai/presentation/screens/health_record_screen.dart';
import 'package:healthylife_ai/presentation/screens/language_settings_screen.dart';
import 'package:healthylife_ai/presentation/screens/meal_detail_screen.dart';
import 'package:healthylife_ai/presentation/screens/measurements_screen.dart';
import 'package:healthylife_ai/presentation/screens/my_requests_screen.dart';
import 'package:healthylife_ai/presentation/screens/new_measurement_screen.dart';
import 'package:healthylife_ai/presentation/screens/notification_settings_screen.dart';
import 'package:healthylife_ai/presentation/screens/notifications_center_screen.dart';
import 'package:healthylife_ai/presentation/screens/onboarding_health_screen.dart';
import 'package:healthylife_ai/presentation/screens/onboarding_measurements_screen.dart';
import 'package:healthylife_ai/presentation/screens/onboarding_notifications_screen.dart';
import 'package:healthylife_ai/presentation/screens/plan_preparing_screen.dart';
import 'package:healthylife_ai/presentation/screens/posts_screens.dart';
import 'package:healthylife_ai/presentation/screens/quantity_selector_screen.dart';
import 'package:healthylife_ai/presentation/screens/quick_request_screen.dart';
import 'package:healthylife_ai/presentation/screens/reviews_screen.dart';
import 'package:healthylife_ai/presentation/screens/schedule_calls_screen.dart';
import 'package:healthylife_ai/presentation/screens/shopping_list_screen.dart';
import 'package:healthylife_ai/presentation/screens/specialist_profile_screen.dart';
import 'package:healthylife_ai/presentation/screens/weekly_plan_screen.dart';
import 'package:healthylife_ai/presentation/screens/wellbeing_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../helpers/app_font.dart';
import '../helpers/sample_meal_plan.dart';
import '../helpers/screen_fixtures.dart';

final _ar = lookupAppLocalizations(const Locale('ar'));

// ───────────────────────────── the two data sets ─────────────────────────────

/// Keys whose numbers are not amounts: ids, paging, enums, versions.
const _fixedKeys = {
  'page',
  'current_page',
  'last_page',
  'per_page',
  'day_index',
  'version',
  'expires_in',
  'sort_order',
  'status',
  'gender',
  'type',
  'code',
  'source',
  'role',
  'kind',
  'reason',
  'meal_type',
  'log_kind',
  'macro',
  'section',
};

/// Keys whose text is written by a person: names, notes, replies, hours.
const _textKeys = {
  'name',
  'name_ar',
  'name_en',
  'title',
  'title_ar',
  'text_ar',
  'motivation_ar',
  'body',
  'body_ar',
  'username',
  'patient_code',
  'notes',
  'details',
  'note',
  'summary',
  'key_points',
  'reply',
  'message',
  'description',
  'question',
  'question_ar',
  'label',
  'label_ar',
  'dose',
  'frequency',
  'window',
  'reply_hours',
};

/// Data set B from data set A.
Object? _vary(Object? v, [String? key]) {
  if (v is Map) {
    return <String, Object?>{
      for (final e in v.entries)
        e.key as String: _vary(e.value, e.key as String),
    };
  }
  if (v is List) return [for (final x in v) _vary(x, key)];
  if (key == null) return v;
  if (v is num && !key.endsWith('id') && !_fixedKeys.contains(key)) {
    return v is int ? v * 2 + 1 : (v * 2 + 1.5);
  }
  if (v is String && _textKeys.contains(key) && v.isNotEmpty) return '$v ب';
  return v;
}

const _patientB = PatientUser(
  id: 5,
  name: 'سارة محمد العتيبي',
  role: 'client',
  nutritionistId: 2,
  subscriberId: 17,
  gender: 'female',
  patientCode: 'HL-0999',
  username: 'sara99',
);

Meal _lunchFrom(Map<String, Object?> json) {
  final lunch = MealPlanDto.fromJson(json)!.meals.firstWhere((m) => m.id == 22);
  return Meal(
    id: '${lunch.id}',
    name: 'الغداء',
    timeRange: '',
    calories: lunch.macros.calories.round(),
    items: [
      for (final i in lunch.items)
        MealItem(name: i.food.name, grams: i.quantityGrams),
    ],
    alternativesText: '',
    status: MealStatus.current,
    iconEmojiSlot: 'sun_orange',
    source: lunch,
  );
}

// ─────────────────────── what may stay the same in both ───────────────────────

/// Dates and times: the two data sets share their dates on purpose, so the
/// day the test runs on shows in both.
final _dateLike = RegExp(r'\d{1,2}/\d{1,2}/\d{4}|\d{1,2}:\d{2}|'
    r'(يناير|فبراير|مارس|أبريل|مايو|يونيو|يوليو|أغسطس|سبتمبر|أكتوبر|نوفمبر|ديسمبر)');

/// Numbers that are copy, not data, per screen: units and quantity presets,
/// server limits, achievement thresholds, step counts, the weight scale.
/// Counts that come from list lengths, which the two data sets share.
final Map<String, List<Pattern>> _copy = {
  'home': [RegExp(r'^\d+/\d+$')],
  'plan tab': [RegExp(r'^\d{1,2}$')],
  'progress tab': [RegExp(r'^(30|90) يوماً$')],
  'weekly plan': [RegExp(r'^\d{1,2}$'), RegExp(r'^الأسبوع \d+ من الخطة$')],
  'meal detail': [RegExp(r'^\d+ أصناف غذائية$')],
  // The food on the quantity screen is passed in, not loaded, so it is the
  // same in both; the presets and the range are copy.
  'quantity': [RegExp(r'.*')],
  'food search': [RegExp(r'^100 غ(رام)?$|لكل 100 غ'), RegExp(r'^\d+ أطعمة$')],
  'measurements': [
    RegExp(r'^(30|90) يوم$'),
    RegExp(r'^بعد \d+ أيام$'),
    // Days logged come from the dates, which the two data sets share.
    RegExp(r'^قياسات هذا الأسبوع: \d+ من 7 أيام$'),
    RegExp(r'^\(أيام مسجّلة هذا الشهر: \d+\)$'),
  ],
  'new measurement': [RegExp(r'^بعد \d+ أيام$')],
  'book appointment': [RegExp(r'^0/300$'), RegExp(r'^(15|30) دقيقة$')],
  'quick request': ['0 / 280'],
  'achievements': [RegExp(r'.*')],
  'wellbeing': ['0 / 280', 'آخر 7 ليالي', 'ليلة أقل من 6 ساعات'],
  'food prefs': ['0 من 30'],
  'onboarding health': [RegExp(r'أوميغا 3'), RegExp(r'^خطوة 2 من 3')],
  'onboarding measurements': [
    RegExp(r'^[1-3]$'),
    RegExp(r'^(40|160) كجم$'),
    '70.5',
    RegExp(r'^خطوة 1 من 3'),
  ],
  'onboarding notifications': [RegExp(r'^خطوة 3 من 3')],
  // The copyright year is today's year, not data.
  'about': [RegExp(r'^© \d{4} HealthyLife AI$')],
};

/// The installed version comes from the build, not from the data.
final _versionLine = RegExp(r'^(الإصدار|HealthyLife — النسخة) \d');

bool _isCopy(String screen, String text) {
  if (_dateLike.hasMatch(text) || _versionLine.hasMatch(text)) return true;
  for (final p in _copy[screen] ?? const <Pattern>[]) {
    if (p is RegExp ? p.hasMatch(text) : p == text) return true;
  }
  return false;
}

final _digit = RegExp(r'[0-9٠-٩]');

Set<String> _texts(WidgetTester tester) => {
      for (final e in find.byType(RichText).evaluate())
        (e.widget as RichText).text.toPlainText().trim(),
    }..remove('');

Future<Set<String>> _render(
  WidgetTester tester,
  Widget Function(bool b) screen, {
  required bool b,
  Future<void> Function(WidgetTester)? act,
  Map<String, Object?> Function(Map<String, Object?>)? routes,
}) async {
  final planA = samplePlanJson();
  await pumpScreen(tester, const Size(412, 3000), (_) => screen(b),
      act: act,
      plan: b ? _vary(planA) as Map<String, Object?> : planA,
      user: b ? _patientB : screenUser, routes: (base) {
    final r = routes == null ? base : routes(base);
    return b ? _vary(r) as Map<String, Object?> : r;
  });
  final texts = _texts(tester);
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 6));
  return texts;
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    PackageInfo.setMockInitialValues(
      appName: 'HealthyLife',
      packageName: 'ai.healthylife.app',
      version: '1.0.0',
      buildNumber: '7',
      buildSignature: '',
    );
    expect(await loadAppFont(), isTrue);
    await loadMaterialIcons();
  });
  setUp(AppVersion.reset);

  const food = SearchableFood(
      id: 7, name: 'صدر دجاج مشوي', caloriesPer100g: 165, macro: 'protein');
  final screens =
      <String, (Widget Function(bool b), Future<void> Function(WidgetTester)?)>{
    'home': ((_) => const AppShell(), null),
    'plan tab': (
      (_) => const AppShell(),
      (t) => t.tap(find.byIcon(Icons.event_note_rounded).first,
          warnIfMissed: false)
    ),
    'progress tab': (
      (_) => const AppShell(),
      (t) =>
          t.tap(find.byIcon(Icons.insights_rounded).first, warnIfMissed: false)
    ),
    'profile tab': (
      (_) => const AppShell(),
      (t) => t.tap(find.byIcon(Icons.person_rounded).first, warnIfMissed: false)
    ),
    'weekly plan': ((_) => const WeeklyPlanScreen(), null),
    'meal detail': (
      (b) => MealDetailScreen(
          meal: _lunchFrom(b
              ? _vary(samplePlanJson()) as Map<String, Object?>
              : samplePlanJson())),
      null
    ),
    'quantity': ((_) => const QuantitySelectorScreen(food: food), null),
    'food search': (
      (_) => const FoodSearchScreen(),
      (t) => t.enterText(find.byType(TextField).first, 'دجاج')
    ),
    'measurements': ((_) => const MeasurementsScreen(), null),
    'new measurement': ((_) => const MeasurementEntryScreen(), null),
    'notifications': ((_) => const NotificationsCenterScreen(), null),
    'notification settings': ((_) => const NotificationSettingsScreen(), null),
    'appointments': ((_) => const ScheduleCallsScreen(), null),
    'book appointment': ((_) => const BookAppointmentScreen(), null),
    'quick request': ((_) => const QuickRequestScreen(), null),
    'my requests': ((_) => const MyRequestsScreen(), null),
    'health record': ((_) => const HealthRecordScreen(), null),
    'specialist': ((_) => const SpecialistProfileScreen(), null),
    'about': ((_) => const AboutAppScreen(), null),
    'language': ((_) => const LanguageSettingsScreen(), null),
    'achievements': ((_) => const AchievementsScreen(), null),
    'posts': ((_) => const PostsScreen(), null),
    'reviews': ((_) => const ReviewsScreen(), null),
    'checkin': ((_) => const CheckinScreen(), null),
    'wellbeing': ((_) => const WellbeingScreen(), null),
    'food prefs': ((_) => const FoodPreferencesScreen(), null),
    'shopping': ((_) => ShoppingListScreen(day: DateTime.now()), null),
    'onboarding health': ((_) => const OnboardingHealthScreen(), null),
    'onboarding measurements': (
      (_) => const OnboardingMeasurementsScreen(),
      null
    ),
    'onboarding notifications': (
      (_) => const OnboardingNotificationsScreen(),
      null
    ),
    'plan preparing': ((_) => const PlanPreparingScreen(), null),
  };

  group('a number that stays the same with other data is copy', () {
    screens.forEach((name, spec) {
      testWidgets(name, (tester) async {
        final a = await _render(tester, spec.$1, b: false, act: spec.$2);
        final b = await _render(tester, spec.$1, b: true, act: spec.$2);
        expect(a, isNotEmpty);
        final frozen = [
          for (final t in a.intersection(b))
            if (_digit.hasMatch(t) && !_isCopy(name, t)) t,
        ]..sort();
        expect(frozen, isEmpty,
            reason: 'on "$name" these did not change with the data');
        // Patient A's name and code do not stay on patient B's screen.
        for (final t in a.intersection(b)) {
          expect(t.contains(screenUser.name), isFalse, reason: 'name in: $t');
          expect(t.contains(screenUser.patientCode!), isFalse,
              reason: 'code in: $t');
        }
      });
    });
  });

  group('the lines this sweep fixed', () {
    testWidgets(
        'plan preparing shows the nutritionist\'s own reply hours, '
        'and no time promise', (tester) async {
      final a =
          await _render(tester, (_) => const PlanPreparingScreen(), b: false);
      final b =
          await _render(tester, (_) => const PlanPreparingScreen(), b: true);
      expect(a,
          contains(_ar.planPreparingReplyHours('الأحد – الخميس، 9 ص – 5 م')));
      expect(b,
          contains(_ar.planPreparingReplyHours('الأحد – الخميس، 9 ص – 5 م ب')));
      for (final t in a) {
        expect(t, isNot(contains('24 ساعة')));
        expect(t, isNot(contains('9:00')));
        expect(t, isNot(contains('٪')));
      }
      expect(a, contains(_ar.planPreparingByNutritionist));
    });

    testWidgets('plan preparing hides the hours line without reply hours',
        (tester) async {
      final texts = await _render(tester, (_) => const PlanPreparingScreen(),
          b: false, routes: (base) {
        final profile = Map<String, Object?>.of(
            base['GET me/nutritionist']! as Map<String, Object?>)
          ..remove('reply_hours');
        return {...base, 'GET me/nutritionist': profile};
      });
      expect(texts.where((t) => t.startsWith('أوقات الرد')), isEmpty);
    });

    testWidgets('language footer: the product name and the real version',
        (tester) async {
      final texts = await _render(tester, (_) => const LanguageSettingsScreen(),
          b: false);
      expect(texts, contains('HealthyLife — النسخة 1.0.0 (7)'));
      expect(texts.where((t) => t.contains('Care Portal')), isEmpty);
      expect(texts.where((t) => t.contains('2.4.0')), isEmpty);
    });

    testWidgets('copyright: this year and the dashboard\'s name',
        (tester) async {
      final texts =
          await _render(tester, (_) => const AboutAppScreen(), b: false);
      expect(texts, contains('© ${DateTime.now().year} HealthyLife AI'));
      expect(texts.where((t) => t.contains('Clinical')), isEmpty);
    });

    testWidgets('initial measurements: no estimated ideal weight',
        (tester) async {
      final texts = await _render(
          tester, (_) => const OnboardingMeasurementsScreen(),
          b: false);
      expect(texts.where((t) => t.contains('المثالي')), isEmpty);
      expect(texts.where((t) => t.contains('65')), isEmpty);
    });

    testWidgets('measurements: the week line is neutral', (tester) async {
      final texts =
          await _render(tester, (_) => const MeasurementsScreen(), b: false);
      expect(texts.where((t) => t.contains('سجّلتِ')), isEmpty);
      expect(texts.any((t) => t.startsWith('قياسات هذا الأسبوع: ')), isTrue);
    });
  });
}
