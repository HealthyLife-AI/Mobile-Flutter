import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/di/app_dependencies.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/theme/app_theme.dart';
import 'package:healthylife_ai/l10n/l10n.dart';
import 'package:healthylife_ai/presentation/bloc/meal_log/meal_log_cubit.dart';
import 'package:healthylife_ai/presentation/screens/home_dashboard_screen.dart';
import 'package:healthylife_ai/presentation/screens/meal_detail_screen.dart';

import '../../helpers/app_font.dart';
import '../../helpers/app_providers.dart';
import '../../helpers/sample_meal_plan.dart';
import '../../helpers/scripted_api.dart';

/// "I ate it": the current meal is logged with one tap, with an undo, and the
/// full path (details, amounts, alternatives) stays one tap away.
void main() {
  final ar = lookupAppLocalizations(const Locale('ar'));

  setUpAll(() async {
    expect(await loadAppFont(), isTrue);
  });

  Map<String, Object?> savedLog() => {
        'id': 90,
        'food': {
          'id': 3,
          'name_ar': 'بيض مسلوق',
          'name_en': 'Boiled egg',
          'status': 'approved',
          'calories_per_100g': 155,
          'protein_g_per_100g': 13,
          'carbs_g_per_100g': 1,
          'fat_g_per_100g': 11,
        },
        'quantity_grams': 100,
        'macros': {'calories': 155, 'protein_g': 13, 'carbs_g': 1, 'fat_g': 11},
        'meal_item_id': 55,
        'meal_type': 'breakfast',
        'is_on_plan': true,
        'log_kind': 'planned',
        'logged_at': DateTime.now().toUtc().toIso8601String(),
        'editable_until': DateTime.now()
            .add(const Duration(hours: 24))
            .toUtc()
            .toIso8601String(),
      };

  Future<(AppDependencies, ScriptedApi)> openHome(
    WidgetTester tester, {
    Map<String, Object?> extra = const {},
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 2400);
    addTearDown(tester.view.reset);
    final api = ScriptedApi({
      'POST me/meal-logs': (SentRequest _) => savedLog(),
      'GET me/meal-logs': {
        'data': <Object>[],
        'meta': {'current_page': 1, 'last_page': 1}
      },
      'DELETE me/meal-logs/90': null,
      ...extra,
    });
    final deps = AppDependencies.inMemory(
        mealPlanSource: FakeMealPlanSource(samplePlanJson()), api: api);
    await tester.pumpWidget(appProviders(const HomeDashboardScreen(),
        dependencies: deps, theme: AppTheme.light));
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    return (deps, api);
  }

  /// Taps «أكلتها» and waits for the confirmation (each item of the meal goes
  /// out one after the other, half a second apart).
  Future<void> eat(WidgetTester tester) async {
    await tester.tap(find.text(ar.mealAte));
    await tester.pump();
    for (var i = 0; i < 40 && find.text(ar.mealUndo).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    // The bar slides in; a tap during that lands off screen.
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 8));
  }

  testWidgets('one tap on «أكلتها» logs the current meal and offers an undo',
      (tester) async {
    final (_, api) = await openHome(tester);

    expect(find.text(ar.mealAte), findsOneWidget);
    await eat(tester);

    expect(api.to('POST', 'me/meal-logs'), isNotEmpty);
    final body = api.to('POST', 'me/meal-logs').first.body! as Map;
    expect(body['meal_item_id'], isNotNull,
        reason: 'logged against the plan, not as an off-plan food');
    expect(find.textContaining('تم تسجيل'), findsOneWidget);
    expect(find.text(ar.mealUndo), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('undo removes the log', (tester) async {
    final (_, api) = await openHome(tester);
    await eat(tester);

    await tester.tap(find.text(ar.mealUndo));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // Each item of the meal was saved with its own id on the server.
    expect(api.to('DELETE', 'me/meal-logs/90'), isNotEmpty);
    final cubit =
        tester.element(find.byType(HomeDashboardScreen)).read<MealLogCubit>();
    expect(cubit.state.entries, isEmpty);
    await unmount(tester);
  });

  testWidgets('the undo is offered for six seconds', (tester) async {
    await openHome(tester);
    await eat(tester);
    expect(find.text(ar.mealUndo), findsOneWidget);

    // Still there four seconds on (6 s is the window; the bar slides in
    // first, so it is a little over six seconds on screen).
    for (var t = 0; t < 4; t++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.text(ar.mealUndo), findsOneWidget);
    // Gone well before it would stay forever: a bar with an action persists
    // unless told otherwise (meal_logged_snack.dart).
    for (var t = 0; t < 6; t++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.text(ar.mealUndo), findsNothing);
    await unmount(tester);
  });

  testWidgets('a second tap while the first is in flight logs nothing more',
      (tester) async {
    final (_, api) = await openHome(tester);

    await tester.tap(find.text(ar.mealAte));
    await tester.tap(find.text(ar.mealAte), warnIfMissed: false);
    await tester.pump();
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    final plan = (samplePlanJson()['meals'] as List).first as Map;
    final itemCount = (plan['items'] as List).length;
    expect(api.to('POST', 'me/meal-logs'), hasLength(itemCount),
        reason: 'one log per item of the one meal, not twice');
    await unmount(tester);
  });

  testWidgets('offline, the log is kept and the undo still works',
      (tester) async {
    final (deps, api) = await openHome(tester, extra: {
      'POST me/meal-logs':
          const NetworkException('offline', kind: NetworkFailureKind.offline),
    });

    await eat(tester);

    expect(find.text(ar.mealUndo), findsOneWidget,
        reason: 'the meal is logged on the device even with no connection');
    expect(await deps.offlineQueue.pendingCount(), greaterThan(0));

    await tester.tap(find.text(ar.mealUndo));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    expect(await deps.offlineQueue.pendingCount(), 0,
        reason: 'undone before it was ever sent');
    expect(api.to('DELETE', 'me/meal-logs/90'), isEmpty);
    await unmount(tester);
  });

  testWidgets('«التفاصيل والبدائل» keeps the full path', (tester) async {
    await openHome(tester);

    await tester.tap(find.text(ar.mealDetailsAndSwaps));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }

    expect(find.byType(MealDetailScreen), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('logging from the details screen closes it and confirms inline',
      (tester) async {
    final (_, api) = await openHome(tester);
    await tester.tap(find.text(ar.mealDetailsAndSwaps));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }

    await tester.tap(find.text(ar.mealDetailLoggedNow).last);
    await tester.pump();
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }

    expect(api.to('POST', 'me/meal-logs'), isNotEmpty);
    expect(find.byType(MealDetailScreen), findsNothing,
        reason: 'back on Home, not on a success screen');
    expect(find.text(ar.mealUndo), findsOneWidget);
    await unmount(tester);
  });
}
