import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/di/app_dependencies.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/theme/app_theme.dart';
import 'package:healthylife_ai/l10n/l10n.dart';
import 'package:healthylife_ai/presentation/bloc/patient_features_cubits.dart';
import 'package:healthylife_ai/presentation/screens/achievements_screen.dart';
import 'package:healthylife_ai/presentation/screens/checkin_screen.dart';
import 'package:healthylife_ai/presentation/screens/food_preferences_screen.dart';
import 'package:healthylife_ai/presentation/screens/health_sync_screen.dart';
import 'package:healthylife_ai/presentation/screens/home_dashboard_screen.dart';
import 'package:healthylife_ai/presentation/screens/medical_reports_screens.dart';
import 'package:healthylife_ai/presentation/screens/my_requests_screen.dart';
import 'package:healthylife_ai/presentation/screens/posts_screens.dart';
import 'package:healthylife_ai/presentation/screens/quick_request_screen.dart';
import 'package:healthylife_ai/presentation/screens/schedule_calls_screen.dart';
import 'package:healthylife_ai/presentation/screens/weekly_plan_screen.dart';
import 'package:healthylife_ai/presentation/screens/wellbeing_screen.dart';
import 'package:healthylife_ai/presentation/widgets/patient_instructions_card.dart';

import '../../helpers/app_font.dart';
import '../../helpers/app_providers.dart';
import '../../helpers/sample_meal_plan.dart';
import '../../helpers/scripted_api.dart';

final _ar = lookupAppLocalizations(const Locale('ar'));

const _line1 = 'قلّل الصوديوم والأطعمة المصنّعة، وفضّل الأكل الطبيعي والطازج.';
const _line2 = 'قِس مستوى السكر قبل الوجبات وبعدها.';
const _line3 = 'حافظ على هدوئك وخصص وقتًا يوميًا لتمارين التنفس.';

String _today() {
  final now = DateTime.now();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${now.year}-${two(now.month)}-${two(now.day)}';
}

Map<String, dynamic> _plan({Object? instructions, List<Object>? activities}) =>
    samplePlanJson()
      ..['patient_instructions'] = instructions
      ..['activities'] = activities ?? const <Object>[];

/// Mounts [screen] with the app's providers, a scripted server and a plan.
Future<(AppDependencies, ScriptedApi, FakeMealPlanSource)> _pump(
  WidgetTester tester,
  Widget screen, {
  Map<String, Object?> routes = const {},
  Map<String, dynamic>? plan,
  Size size = const Size(390, 1600),
  void Function(BuildContext context)? beforeShow,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  final api = ScriptedApi(routes);
  final source = FakeMealPlanSource(plan ?? _plan());
  final deps = AppDependencies.inMemory(mealPlanSource: source, api: api);
  await tester.pumpWidget(appProviders(
    Builder(builder: (context) {
      beforeShow?.call(context);
      return screen;
    }),
    dependencies: deps,
    theme: AppTheme.light,
  ));
  await _settle(tester);
  return (deps, api, source);
}

/// pumpAndSettle never returns on screens with a looping shimmer.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  setUpAll(loadAppFont);

  group('plan: the nutritionist\'s instructions', () {
    testWidgets('one bullet per line, above the meals', (tester) async {
      await _pump(tester, const WeeklyPlanScreen(),
          plan: _plan(instructions: '$_line1\n$_line2\n$_line3'));

      expect(find.text(_ar.planInstructionsTitle), findsOneWidget);
      for (final line in [_line1, _line2, _line3]) {
        expect(find.text(line), findsOneWidget);
      }
      expect(find.text(_ar.commonShowAll), findsNothing);
      expect(
        tester.getTopLeft(find.text(_ar.planInstructionsTitle)).dy,
        lessThan(tester.getTopLeft(find.text(_ar.mealTypeBreakfast).first).dy),
      );
      await _unmount(tester);
    });

    testWidgets('more than three lines sit behind "عرض الكل"', (tester) async {
      await _pump(tester, const WeeklyPlanScreen(),
          plan: _plan(instructions: '$_line1\n$_line2\n$_line3\nرابع\nخامس'));
      expect(find.text('رابع'), findsNothing);

      await tester.ensureVisible(find.text(_ar.commonShowAll));
      await tester.tap(find.text(_ar.commonShowAll));
      await _settle(tester);
      expect(find.text('رابع'), findsOneWidget);
      expect(find.text('خامس'), findsOneWidget);

      await tester.tap(find.text(_ar.commonShowLess));
      await _settle(tester);
      expect(find.text('رابع'), findsNothing);
      await _unmount(tester);
    });

    for (final (label, value) in [
      ('null', null),
      ('empty', ''),
      ('blank', '  \n \t\n '),
    ]) {
      testWidgets('hidden entirely when $label', (tester) async {
        await _pump(tester, const WeeklyPlanScreen(),
            plan: _plan(instructions: value));
        expect(find.byType(PatientInstructionsCard), findsNothing);
        expect(find.text(_ar.planInstructionsTitle), findsNothing);
        await _unmount(tester);
      });
    }

    testWidgets('pull-to-refresh shows the new text', (tester) async {
      final (_, _, source) = await _pump(tester, const WeeklyPlanScreen(),
          plan: _plan(instructions: _line1));
      source.plan = _plan(instructions: 'تعليمات محدّثة');

      await tester.fling(
          find.byType(ListView).first, const Offset(0, 900), 1200);
      await _settle(tester);
      expect(find.text('تعليمات محدّثة'), findsOneWidget);
      expect(find.text(_line1), findsNothing);
      await _unmount(tester);
    });

    testWidgets('activities, with the spec\'s count wording', (tester) async {
      // Tall enough that the section under the meals is built.
      await _pump(tester, const WeeklyPlanScreen(),
          size: const Size(390, 4000),
          plan: _plan(activities: [
            {
              'id': 1,
              'title': 'مشي خفيف',
              'duration_minutes': 30,
              'times_per_day': 2,
              'days_per_week': 5,
            },
            {
              'id': 2,
              'title': 'تمارين تمدد',
              'duration_minutes': 2,
              'times_per_day': 1,
              'days_per_week': null,
            },
          ]));
      expect(find.text(_ar.planActivitiesTitle), findsOneWidget);
      expect(find.text('30 دقيقة'), findsOneWidget);
      expect(find.text('مرتين يوميًا'), findsOneWidget);
      expect(find.text('5 أيام بالأسبوع'), findsOneWidget);
      expect(find.text('دقيقتين'), findsOneWidget);
      expect(find.text('مرة يوميًا'), findsOneWidget);
      expect(find.textContaining('بالأسبوع'), findsOneWidget,
          reason: 'no days badge when days_per_week is null');
      await _unmount(tester);
    });

    testWidgets('no activities: no section', (tester) async {
      await _pump(tester, const WeeklyPlanScreen());
      expect(find.text(_ar.planActivitiesTitle), findsNothing);
      await _unmount(tester);
    });
  });

  group('home', () {
    testWidgets('today card, due reminder and the open-requests badge',
        (tester) async {
      await _pump(
        tester,
        const HomeDashboardScreen(),
        routes: {
          'GET me/today': {
            'date': _today(),
            'meals': [
              {'name': 'breakfast', 'name_ar': 'الفطور', 'window': 'الصبح'},
            ],
            'reminders': [
              {'type': 'checkin', 'text_ar': 'عندك استبيان قصير من أخصائيتك.'},
            ],
            'motivation_ar': 'المهم ترجع للخطة بالوجبة الجاية.',
          },
          'GET me/measurement-schedule': {
            'interval_days': 14,
            'next_due_on': _today(),
          },
          'GET me/quick-requests': [
            {
              'id': 1,
              'reason': 'craving',
              'status': 'open',
              'created_at': '2026-11-01T10:00:00Z'
            },
            {
              'id': 2,
              'reason': 'other',
              'status': 'open',
              'created_at': '2026-11-02T10:00:00Z'
            },
            {
              'id': 3,
              'reason': 'other',
              'status': 'answered',
              'created_at': '2026-10-02T10:00:00Z'
            },
          ],
        },
        beforeShow: (context) {
          context.read<TodayCubit>().load();
          context.read<MeasurementScheduleCubit>().load();
          context.read<QuickRequestsCubit>().load();
        },
      );
      expect(find.text(_ar.todayTitle), findsOneWidget);
      expect(find.text('عندك استبيان قصير من أخصائيتك.'), findsOneWidget);
      expect(find.text('المهم ترجع للخطة بالوجبة الجاية.'), findsOneWidget);
      expect(find.text(_ar.scheduleDueTitle), findsOneWidget);
      await tester.scrollUntilVisible(find.text(_ar.quickContactTitle), 300,
          scrollable: find.byType(Scrollable).first);
      expect(find.text(_ar.requestsAwaiting('2')), findsOneWidget);
      await _unmount(tester);
    });

    testWidgets('no due reminder before the date', (tester) async {
      await _pump(
        tester,
        const HomeDashboardScreen(),
        routes: {
          'GET me/measurement-schedule': {
            'interval_days': 7,
            'next_due_on': '2999-01-01',
          },
        },
        beforeShow: (context) =>
            context.read<MeasurementScheduleCubit>().load(),
      );
      expect(find.text(_ar.scheduleDueTitle), findsNothing);
      await _unmount(tester);
    });
  });

  group('quick contact', () {
    testWidgets(
        'the date field only for a special occasion; send needs a reason',
        (tester) async {
      await _pump(tester, const QuickRequestScreen());
      final send = find.widgetWithText(FilledButton, _ar.quickRequestSend);
      expect(tester.widget<FilledButton>(send).onPressed, isNull);
      expect(find.text(_ar.quickRequestOccasionDate), findsNothing);

      await tester.tap(find.text(_ar.reasonSpecialOccasion));
      await _settle(tester);
      expect(find.text(_ar.quickRequestOccasionDate), findsOneWidget);
      expect(tester.widget<FilledButton>(send).onPressed, isNotNull);

      await tester.tap(find.text(_ar.reasonCraving));
      await _settle(tester);
      expect(find.text(_ar.quickRequestOccasionDate), findsNothing);
      await _unmount(tester);
    });

    testWidgets('the daily limit (429) is explained', (tester) async {
      await _pump(tester, const QuickRequestScreen(), routes: {
        'POST me/quick-requests': const ApiException('limit',
            statusCode: 429, code: 'quick_request_limit'),
      });
      await tester.tap(find.text(_ar.reasonOther));
      await _settle(tester);
      await tester.ensureVisible(find.text(_ar.quickRequestSend));
      await tester.tap(find.text(_ar.quickRequestSend));
      await _settle(tester);
      expect(find.text(_ar.quickRequestLimit), findsOneWidget);
      await _unmount(tester);
    });

    testWidgets('my requests: statuses and the reply', (tester) async {
      await _pump(tester, const MyRequestsScreen(), routes: {
        'GET me/quick-requests': [
          {
            'id': 7,
            'reason': 'special_occasion',
            'note': 'عرس صديقتي',
            'status': 'answered',
            'response': 'ابدئي بصحن سلطة.',
            'responded_at': '2026-10-24T13:10:00Z',
            'created_at': '2026-10-24T10:00:00Z',
          },
        ],
      });
      expect(find.text(_ar.requestStatusAnswered), findsOneWidget);
      expect(find.text('ابدئي بصحن سلطة.'), findsOneWidget);
      expect(find.text('«عرس صديقتي»'), findsOneWidget);
      await _unmount(tester);
    });
  });

  group('check-in', () {
    final checkin = {
      'id': 12,
      'questions': [
        {
          'key': 'barriers',
          'type': 'multi',
          'max': 2,
          'label': 'شو أكثر شي صعّب عليك؟',
          'options': [
            {'value': 'time', 'label': 'الوقت'},
            {'value': 'budget', 'label': 'الميزانية'},
            {'value': 'mood', 'label': 'المزاج'},
            {'value': 'none', 'label': 'ولا شي'},
          ],
        },
      ],
    };

    testWidgets('next waits for an answer; the limit and "none" hold',
        (tester) async {
      final (_, api, _) = await _pump(tester, const CheckinScreen(), routes: {
        'GET me/checkins/current': checkin,
        'POST me/checkins/12': {'status': 'submitted'},
      });
      final submit = find.widgetWithText(FilledButton, _ar.checkinSubmit);
      expect(tester.widget<FilledButton>(submit).onPressed, isNull);

      await tester.tap(find.text('الوقت'));
      await tester.tap(find.text('الميزانية'));
      await tester.tap(find.text('المزاج'));
      await _settle(tester);
      expect(find.text(_ar.checkinLimitReached('2')), findsOneWidget);

      await tester.tap(find.text('ولا شي'));
      await _settle(tester);
      await tester.tap(submit);
      await _settle(tester);
      expect(api.to('POST', 'me/checkins/12').single.body, {
        'answers': {
          'barriers': ['none']
        }
      });
      expect(find.text(_ar.checkinThanks), findsOneWidget);
      await _unmount(tester);
    });

    testWidgets('an expired check-in says so', (tester) async {
      await _pump(tester, const CheckinScreen(), routes: {
        'GET me/checkins/current': checkin,
        'POST me/checkins/12': const ApiException('expired',
            statusCode: 409, code: 'checkin_expired'),
      });
      await tester.tap(find.text('الوقت'));
      await _settle(tester);
      await tester.tap(find.text(_ar.checkinSubmit));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(_ar.checkinExpired), findsOneWidget);
      await _unmount(tester);
    });
  });

  group('medical reports', () {
    testWidgets('hidden with no message while the feature is off (404)',
        (tester) async {
      await _pump(tester, const Scaffold(body: MedicalReportsSection()));
      expect(find.text(_ar.reportsTitle), findsNothing);
      expect(find.text(_ar.reportsConsentTitle), findsNothing);
      expect(find.text(_ar.reportsLoadFailed), findsNothing);
      await _unmount(tester);
    });

    testWidgets('consent first, then the list with its counter',
        (tester) async {
      final (_, api, _) = await _pump(
        tester,
        const Scaffold(
            body: SingleChildScrollView(child: MedicalReportsSection())),
        routes: {
          'GET me/consent': {
            'current_version': 'reports-1',
            'accepted_version': null,
            'text_ar': 'النص الكامل للموافقة',
          },
          'POST me/consent': {'ok': true},
          'GET me/reports': [
            {
              'id': 3,
              'category': 'lab_test',
              'title': 'فحص السكر التراكمي',
              'mime': 'application/pdf',
              'size_bytes': 348160,
              'reviewed': true,
              'nutritionist_note': 'النتيجة أحسن من المرة الماضية.',
            },
          ],
        },
      );
      expect(find.text(_ar.reportsConsentTitle), findsOneWidget);
      await tester.tap(find.text(_ar.reportsConsentAgree));
      await _settle(tester);
      expect(api.to('POST', 'me/consent').single.body,
          {'type': 'medical_reports'});
      expect(find.text('فحص السكر التراكمي'), findsOneWidget);
      expect(find.text(_ar.reportReviewed), findsOneWidget);
      expect(find.text(_ar.reportsCount('1', '30')), findsOneWidget);
      await _unmount(tester);
    });
  });

  group('sleep and mood', () {
    testWidgets('save waits for one field, then sends the whole night',
        (tester) async {
      final (_, api, _) = await _pump(tester, const WellbeingScreen(), routes: {
        'GET me/wellbeing': <Object>[],
        'PUT me/wellbeing/${_yesterday()}': (SentRequest r) =>
            {'date': _yesterday(), ...(r.body as Map)},
      });
      final save = find.widgetWithText(FilledButton, _ar.commonSave);
      expect(tester.widget<FilledButton>(save).onPressed, isNull);

      await tester.tap(find.byTooltip(_ar.wellbeingMoreSleep));
      await tester.tap(find.text(_ar.wellbeingStressHigh));
      await _settle(tester);
      await tester.ensureVisible(save);
      await tester.tap(save);
      await _settle(tester);
      expect(api.to('PUT', 'me/wellbeing/${_yesterday()}').single.body,
          {'sleep_hours': 7, 'stress': 'high'});
      await _unmount(tester);
    });
  });

  group('new screens fit the narrowest phone', () {
    final screens = <String, (Widget, Map<String, Object?>)>{
      'quick request': (const QuickRequestScreen(), const {}),
      'my requests': (
        const MyRequestsScreen(),
        {
          'GET me/quick-requests': [
            {
              'id': 1,
              'reason': 'cannot_continue',
              'note': 'الخطة صعبة عليّ هالفترة بسبب الدوام والدراسة',
              'status': 'open',
              'created_at': '2026-11-01T21:20:00Z',
            },
          ],
        }
      ),
      'check-in': (
        const CheckinScreen(),
        {
          'GET me/checkins/current': {
            'id': 1,
            'questions': [
              {
                'key': 'adherence',
                'type': 'single',
                'label': 'كيف كان التزامك بالخطة هالفترة؟',
                'options': [
                  {'value': 'good', 'label': 'جيد'},
                ],
              },
            ],
          },
        }
      ),
      'food preferences': (
        const FoodPreferencesScreen(),
        {
          'GET me/food-preferences': {
            'likes': [
              {'food_id': 4, 'name_ar': 'عدس مطبوخ', 'source': 'nutritionist'},
            ],
            'dislikes': <Object>[],
          },
        }
      ),
      'posts': (
        const PostsScreen(),
        {
          'GET me/posts': {
            'data': [
              {
                'id': 1,
                'title': 'قبل العزومة، كل شي خفيف',
                'body': 'لما تكون معزوم، كل حبة فاكهة أو صحن سلطة قبل بساعة.',
                'pinned': true,
                'is_read': false,
                'published_at': '2026-11-02T08:00:00Z',
              },
            ],
            'meta': {'current_page': 1, 'last_page': 1},
          },
        }
      ),
      'wellbeing': (const WellbeingScreen(), {'GET me/wellbeing': <Object>[]}),
      'report upload': (const ReportUploadScreen(), const {}),
      'achievements': (const AchievementsScreen(), const {}),
      'health sync': (const HealthSyncScreen(), const {}),
      'appointments': (
        const ScheduleCallsScreen(),
        {
          'GET me/appointments': [
            {
              'id': 1,
              'type': 'follow_up',
              'channel': 'video',
              'starts_at': '2999-01-01T10:00:00+02:00',
              'status': 'booked',
            },
          ],
        }
      ),
      'plan with instructions': (
        const WeeklyPlanScreen(),
        const {},
      ),
    };

    screens.forEach((name, entry) {
      testWidgets(name, (tester) async {
        final errors = <String>[];
        final previous = FlutterError.onError;
        FlutterError.onError =
            (details) => errors.add(details.exceptionAsString());
        try {
          await _pump(tester, entry.$1,
              routes: entry.$2,
              size: const Size(320, 640),
              plan: _plan(instructions: '$_line1\n$_line2', activities: [
                {
                  'id': 1,
                  'title': 'مشي خفيف بعد الغداء',
                  'duration_minutes': 30,
                  'times_per_day': 2,
                  'days_per_week': 5,
                },
              ]));
        } finally {
          FlutterError.onError = previous;
        }
        expect(errors.where((e) => e.contains('overflowed')), isEmpty,
            reason: errors.join('\n'));
        await _unmount(tester);
      });
    });
  });
}

String _yesterday() {
  final now = DateTime.now();
  final d = DateTime(now.year, now.month, now.day - 1);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}
