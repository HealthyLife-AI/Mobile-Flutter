// Audit (pre-launch 2026-11), invariant I9: does mobile `main` parse what the
// backend really sends? Every repository the app uses reads REAL captured JSON
// (test/audit/fixtures, from capture_fixtures.py) through the real Dio client.
// A failing expectation here is a contract break for installed apps.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/di/app_dependencies.dart';
import 'package:healthylife_ai/core/errors/result.dart';
import 'package:healthylife_ai/data/models/server_meal_log.dart';
import 'package:healthylife_ai/domain/entities/appointment_entities.dart';

import 'fixture_api.dart';

AppDependencies _deps(FixtureAdapter adapter) =>
    AppDependencies.inMemory(api: fixtureClient(adapter));

Object? _ok(Result<dynamic> r, String what) {
  expect(r.isSuccess, isTrue,
      reason: '$what failed to parse real JSON: ${r.failureOrNull}');
  return r.valueOrNull;
}

Map<String, dynamic> _body(String name) =>
    Fixture.load(name).body as Map<String, dynamic>;

void main() {
  for (final variant in ['', 'empty_']) {
    final label = variant.isEmpty ? 'rich account' : 'empty account';
    group('every read the app makes parses ($label)', () {
      late FixtureAdapter adapter;
      late AppDependencies deps;
      setUp(() {
        adapter = FixtureAdapter(defaultRoutes, prefix: variant);
        deps = _deps(adapter);
      });

      test('meal plan', () async {
        final plan = _ok(await deps.mealPlan.getActivePlan(), 'plan');
        if (variant.isEmpty) {
          final raw = _body('me_meal_plan');
          final rawMeals = raw['meals'] as List;
          expect((plan as dynamic).meals.length, rawMeals.length);
        } else {
          expect(plan, isNull, reason: 'no active plan -> 204 -> null');
        }
      });
      test('measurements', () async {
        _ok(await deps.measurement.getSnapshot(), 'measurements');
      });
      test('nutritionist', () async {
        _ok(await deps.nutritionist.getProfile(), 'nutritionist');
      });
      test('health profile', () async {
        _ok(await deps.patientHealthProfile.getProfile(), 'health profile');
      });
      test('reviews', () async {
        _ok(await deps.reviews.getReviews(), 'reviews');
      });
      test('progress', () async {
        final now = DateTime.now();
        _ok(
            await deps.progress.getProgress(
                from: now.subtract(const Duration(days: 1)), to: now),
            'progress');
      });
      test('appointments + slots', () async {
        _ok(
            await deps.appointments
                .getAppointments(scope: AppointmentScope.upcoming),
            'appointments');
        if (variant.isEmpty) {
          _ok(await deps.appointments.getSlots(AppointmentType.followUp),
              'slots');
        }
      });
      test('notifications inbox + unread + preferences', () async {
        _ok(await deps.notification.getPage(1), 'inbox');
        _ok(await deps.notification.unreadCount(), 'unread');
        _ok(await deps.notificationPreferences.get(), 'preferences');
      });
      test('patient-spec features', () async {
        _ok(await deps.measurementSchedule.getSchedule(), 'schedule');
        _ok(await deps.quickRequests.getRequests(), 'quick requests');
        _ok(await deps.checkins.getCurrent(), 'checkin');
        _ok(await deps.foodPreferences.get(), 'food preferences');
        _ok(await deps.insights.getGoalProjection(), 'goal projection');
        _ok(await deps.insights.getWeightInsight(), 'weight insight');
        _ok(await deps.today.getToday(), 'today');
        _ok(await deps.posts.getPage(1), 'posts');
        _ok(await deps.medicalReports.getReports(), 'reports (404 = off)');
        final now = DateTime.now();
        _ok(
            await deps.wellbeing
                .getRange(now.subtract(const Duration(days: 1)), now),
            'wellbeing');
      });
      test('meal-log day sync', () async {
        _ok(await deps.mealLog.syncDay(DateTime.now()), 'meal-log sync');
      });
      tearDown(() {
        expect(adapter.unrouted, isEmpty,
            reason: 'the app called endpoints with no fixture');
      });
    });
  }

  group('field-level contract', () {
    test('food search parses every row', () async {
      final adapter = FixtureAdapter(defaultRoutes);
      final foods = _ok(await _deps(adapter).food.search('خبز'), 'search')
          as List;
      expect(foods.length, (_body('foods_search')['data'] as List).length);
    });

    test('a meal-log row from the server parses (POST, replay, PATCH, GET)',
        () {
      for (final name in [
        'me_meal_logs_post_planned',
        'me_meal_logs_post_replay',
        'me_meal_logs_post_offplan',
        'me_meal_logs_patch',
      ]) {
        expect(ServerMealLog.fromJson(_body(name)), isNotNull, reason: name);
      }
      for (final row in _body('me_meal_logs_index')['data'] as List) {
        expect(ServerMealLog.fromJson(row as Map<String, dynamic>), isNotNull);
      }
    });

    // The server stores quantity_grams as decimal(6,1) and accepts numeric
    // values; the plan designer saves 60.5 g. The app reads grams as int.
    test('MO: a fractional plan quantity is rounded by the app', () async {
      final adapter = FixtureAdapter(defaultRoutes);
      final plan = _ok(await _deps(adapter).mealPlan.getActivePlan(), 'plan')
          as dynamic;
      final raw = (_body('me_meal_plan')['meals'] as List)
          .expand((m) => (m as Map)['items'] as List)
          .map((i) => (i as Map)['quantity_grams'] as num)
          .toList();
      final app = <int>[
        for (final m in plan.meals)
          for (final i in m.items) i.quantityGrams as int
      ];
      // Documented, not asserted as a failure: 60.5 -> 61.
      // ignore: avoid_print
      print('plan grams server=$raw app=$app');
      expect(raw, contains(60.5));
    });

    test('MO: a meal log with fractional grams is DROPPED by the app parser',
        () {
      final row = Map<String, dynamic>.of(_body('me_meal_logs_post_offplan'))
        ..['quantity_grams'] = 60.5;
      // The backend accepts 60.5 (numeric, decimal(6,1)). The app's
      // jsonInt(60.5) is null, so the whole log is skipped on sync.
      expect(ServerMealLog.fromJson(row), isNotNull,
          reason: 'fractional grams make the log invisible in the app');
    });

    test('enum values the app does not know (inventory)', () {
      final seen = <String, Set<String>>{};
      void walk(Object? v) {
        if (v is Map) {
          v.forEach((k, x) {
            if (x is String &&
                RegExp(r'^[a-z][a-z_]+$').hasMatch(x) &&
                const {
                  'status', 'type', 'category', 'source', 'rating', 'kind',
                  'action', 'channel', 'meal_type', 'log_kind', 'reason',
                  'name', 'goal_type', 'activity_level', 'class', 'group',
                  'timing', 'shopping_section', 'sleep_quality', 'stress',
                  'mood', 'cancelled_by', 'gender', 'role'
                }.contains(k)) {
              seen.putIfAbsent(k as String, () => {}).add(x);
            }
            walk(x);
          });
        } else if (v is List) {
          v.forEach(walk);
        }
      }

      for (final f in Directory(Fixture.dir).listSync()) {
        if (!f.path.endsWith('.json') || f.path.endsWith('_index.json')) {
          continue;
        }
        walk((jsonDecode(File(f.path).readAsStringSync()) as Map)['body']);
      }
      final lib = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .map((f) => f.readAsStringSync())
          .join('\n');
      final unknown = <String>[];
      seen.forEach((k, values) {
        for (final v in values) {
          if (!lib.contains("'$v'")) unknown.add('$k=$v');
        }
      });
      // ignore: avoid_print
      print('server enum values never named in lib/: $unknown');
    });
  });
}
