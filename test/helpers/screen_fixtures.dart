// Shared fixtures for the screen tests that render whole screens with the
// app's Cairo font and a scripted API: the screenshots in test/goldens and the
// layout checks in test/presentation/flow_layout_test.dart.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/di/app_dependencies.dart';
import 'package:healthylife_ai/core/network/auth_tokens.dart';
import 'package:healthylife_ai/core/theme/app_theme.dart';
import 'package:healthylife_ai/domain/entities/auth_entities.dart';
import 'package:healthylife_ai/presentation/bloc/auth/auth_cubit.dart';
import 'package:healthylife_ai/presentation/bloc/meal_log/meal_log_cubit.dart';
import 'package:healthylife_ai/presentation/bloc/measurements/measurements_cubit.dart';
import 'package:healthylife_ai/presentation/bloc/notifications/notifications_cubit.dart';
import 'package:healthylife_ai/presentation/bloc/patient_features_cubits.dart';

import 'app_providers.dart';
import 'sample_meal_plan.dart';
import 'scripted_api.dart';

String dateOnly(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

Map<String, Object?> screenRoutes() {
  final now = DateTime.now();
  DateTime ago(int days) => DateTime(now.year, now.month, now.day - days);
  return {
    'GET me/today': {
      'date': dateOnly(now),
      'meals': [
        {'name': 'breakfast', 'name_ar': 'الفطور', 'window': 'الصبح'},
        {'name': 'lunch', 'name_ar': 'الغداء', 'window': 'الظهر'},
      ],
      'reminders': [
        {'type': 'checkin', 'text_ar': 'عندك استبيان قصير من أخصائيتك.'},
      ],
      'motivation_ar': 'المهم ترجع للخطة بالوجبة الجاية.',
    },
    'POST auth/refresh': {
      'access_token': 'a2',
      'refresh_token': 'r2',
      'token_type': 'Bearer',
      'expires_in': 900
    },
    'GET auth/me': {
      'id': 5,
      'name': 'عبد الرحمن بن عبد العزيز الشمراني',
      'role': 'client',
      'nutritionist_id': 2,
      'subscriber_id': 17,
      'gender': 'male',
      'patient_code': 'HL-0017',
      'username': 'abdulrahman17',
      'password_is_temporary': false
    },
    'GET me/consent': {
      'current_version': '1',
      'accepted_version': '1',
      'accepted_at': '2026-10-01T09:00:00+00:00',
      'policy_url': 'https://example.com/ar/privacy'
    },
    'GET me/measurement-schedule': {
      'interval_days': 7,
      'next_due_on': dateOnly(now.add(const Duration(days: 3))),
    },
    'GET me/quick-requests': <Object>[],
    'GET me/posts/unread-count': {'unread': 2},
    'GET me/notifications/unread-count': {'unread': 3},
    'GET me/notifications': {
      'data': [
        {
          'id': 1,
          'category': 'plan',
          'type': 'plan_updated',
          'title': 'تم تحديث خطتك الغذائية',
          'body': 'أضافت أخصائيتك وجبة خفيفة بعد الظهر. افتح الخطة لتراها.',
          'data': <String, Object?>{},
          'read_at': null,
          'created_at': now.toUtc().toIso8601String(),
          'updated_at': now.toUtc().toIso8601String(),
        },
        {
          'id': 2,
          'category': 'measurements',
          'type': 'measurement_due',
          'title': 'حان موعد قياس الوزن',
          'body': 'سجّل وزنك اليوم لتتابع أخصائيتك تقدمك.',
          'data': <String, Object?>{},
          'read_at': null,
          'created_at': ago(1).toUtc().toIso8601String(),
          'updated_at': ago(1).toUtc().toIso8601String(),
        },
        {
          'id': 3,
          'category': 'nutritionist',
          'type': 'review',
          'title': 'ملاحظة جديدة من أخصائيتك',
          'body': 'التزام رائع بوجبة الفطور هذا الأسبوع يا عبد الرحمن.',
          'data': <String, Object?>{},
          'read_at': ago(1).toUtc().toIso8601String(),
          'created_at': ago(2).toUtc().toIso8601String(),
          'updated_at': ago(2).toUtc().toIso8601String(),
        },
      ],
      'meta': {'current_page': 1, 'last_page': 1, 'total': 3},
    },
    'GET me/measurements': [
      for (var i = 0; i < 6; i++)
        {
          'id': i + 1,
          'recorded_at': dateOnly(ago((5 - i) * 7)),
          'source': i == 0 ? 'clinic-analyser' : 'self-reported',
          'weight_kg': 86 - i * 0.8,
          'waist_cm': 96 - i * 0.6,
          'hip_cm': 104 - i * 0.4,
          'deletable_until': null,
        },
    ],
    'GET me/progress': {
      'weight_trend': [
        for (var i = 0; i < 6; i++)
          {
            'recorded_at': dateOnly(ago((5 - i) * 7)),
            'weight_kg': 86 - i * 0.8,
            'source': 'self-reported',
          },
      ],
      'adherence': {'adherence_percent': 78},
    },
    'GET me/nutritionist': {
      'name': 'د. فاطمة الزهراء عبد الرحمن',
      'gender': 'female',
      'whatsapp_number': '+966500000000',
    },
    'GET me/reviews': [
      {
        'id': 12,
        'rating': 'on_track',
        'note': 'التزام رائع بوجبة الفطور هذا الأسبوع.',
        'key_points': ['قلّل الخبز الأبيض في العشاء'],
        'tasks': [
          {'id': 40, 'title': 'اشرب 8 أكواب ماء يومياً', 'done_at': null},
        ],
        'acknowledged_at': null,
        'edited_at': null,
        'created_at': ago(2).toUtc().toIso8601String(),
      },
    ],
    'GET me/appointments': <Object>[],
    'GET me/meal-logs': {
      'data': <Object>[],
      'meta': {'current_page': 1, 'last_page': 1},
    },
    'GET foods/search': {
      'data': [
        for (final f in const [
          [3, 'بيض مسلوق', 'Boiled egg', 155.0, 13.0, 1.1, 11.0],
          [7, 'صدر دجاج مشوي', 'Grilled chicken breast', 165.0, 31.0, 0.0, 3.6],
          [9, 'أرز أبيض مطبوخ', 'Cooked white rice', 130.0, 2.7, 28.0, 0.3],
          [
            12,
            'سلطة خضراء بزيت الزيتون والليمون',
            'Green salad',
            60.0,
            1.5,
            6.0,
            3.5
          ],
          [15, 'لبن زبادي قليل الدسم', 'Low-fat yogurt', 63.0, 5.3, 7.0, 1.6],
        ])
          {
            'id': f[0],
            'name_ar': f[1],
            'name_en': f[2],
            'source': 'admin',
            'status': 'approved',
            'calories_per_100g': f[3],
            'protein_g_per_100g': f[4],
            'carbs_g_per_100g': f[5],
            'fat_g_per_100g': f[6],
            'fiber_g_per_100g': null,
            'allergens': <String>[],
            'shopping_section': 'other',
            'cost_tier': 'economical',
            'prep_level': 'easy',
          },
      ],
      'meta': {'current_page': 1, 'last_page': 1},
    },
    'GET me/health-profile': <String, Object?>{},
    'GET me/food-preferences': {'likes': <Object>[], 'dislikes': <Object>[]},
  };
}

Future<void> loadMaterialIcons() async {
  // The icon font ships with the Flutter SDK, not with the app's assets.
  final file = File('${Platform.environment['FLUTTER_ROOT']}'
      '/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  final loader = FontLoader('MaterialIcons')
    ..addFont(file
        .readAsBytes()
        .then((b) => ByteData.view(Uint8List.fromList(b).buffer)));
  await loader.load();
}

const screenUser = PatientUser(
  id: 5,
  name: 'عبد الرحمن بن عبد العزيز الشمراني',
  role: 'client',
  nutritionistId: 2,
  subscriberId: 17,
  gender: 'male',
  patientCode: 'HL-0017',
  username: 'abdulrahman17',
);


/// Mounts [screen] at [size] (a phone, at 2x), signed in as [screenUser], with
/// the cubits the shell loads on entry, and lets the data arrive. Returns the
/// key of the [RepaintBoundary] around it, for a screenshot. The caller
/// unmounts the screen when it is done, so timers are disposed.
Future<GlobalKey> pumpScreen(
  WidgetTester tester,
  Size size,
  Widget Function(AppDependencies deps) screen, {
  Future<void> Function(WidgetTester tester)? act,
  bool signedIn = true,
  Map<String, Object?> Function(Map<String, Object?>)? routes,
  Locale locale = const Locale('ar'),
  double textScale = 1.0,
}) async {
  tester.view.devicePixelRatio = 2;
  tester.view.physicalSize = size * 2;
  addTearDown(tester.view.reset);
  final base = screenRoutes();
  final api = ScriptedApi(routes == null ? base : routes(base));
  final deps = AppDependencies.inMemory(
      mealPlanSource: FakeMealPlanSource(samplePlanJson()), api: api);
  if (signedIn) {
    await tester.runAsync(() => deps.session.save(const StoredSession(
          tokens: AuthTokens(accessToken: 'a', refreshToken: 'r'),
          user: screenUser,
          onboardingCompleted: true,
        )));
  }
  var loaded = false;
  final key = GlobalKey();
  await tester.pumpWidget(RepaintBoundary(
    key: key,
    child: MediaQuery(
      data: MediaQueryData(
        textScaler: TextScaler.linear(textScale),
        size: size,
        devicePixelRatio: 2,
        padding: const EdgeInsets.only(top: 24),
      ),
      child: appProviders(
        Builder(builder: (context) {
          if (!loaded) {
            loaded = true;
            if (signedIn) context.read<AuthCubit>().start();
            context.read<NotificationsCubit>().load();
            context.read<MeasurementsCubit>().load();
            context.read<MeasurementScheduleCubit>().load();
            context.read<QuickRequestsCubit>().load();
            context.read<TodayCubit>().load();
            context.read<PostsUnreadCubit>().load();
            context.read<MealLogCubit>().load();
          }
          return screen(deps);
        }),
        dependencies: deps,
        theme: AppTheme.light,
        locale: locale,
      ),
    ),
  ));
  for (var i = 0; i < 20; i++) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
    await tester.pump(const Duration(milliseconds: 200));
  }
  if (act != null) {
    await act(tester);
    for (var i = 0; i < 14; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 5)));
      await tester.pump(const Duration(milliseconds: 200));
    }
  }
  return key;
}
