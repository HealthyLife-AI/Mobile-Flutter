import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/di/app_dependencies.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/theme/app_theme.dart';
import 'package:healthylife_ai/l10n/l10n.dart';
import 'package:healthylife_ai/presentation/bloc/meal_log/meal_log_cubit.dart';
import 'package:healthylife_ai/presentation/screens/home_dashboard_screen.dart';
import 'package:healthylife_ai/presentation/screens/meal_detail_screen.dart';

import '../../helpers/app_providers.dart';
import '../../helpers/sample_meal_plan.dart';

/// The screens show the plan the nutritionist set (API guide 5.1), not demo
/// content, and a meal logged from it records what the patient picked.
void main() {
  final ar = lookupAppLocalizations(const Locale('ar'));

  setUpAll(() async {
    // Real glyph widths, as on the device.
    final loader = FontLoader('Tajawal');
    for (final face in ['Regular', 'Medium', 'Bold', 'ExtraBold']) {
      loader.addFont(Future.value(ByteData.sublistView(
          File('assets/fonts/Tajawal-$face.ttf').readAsBytesSync())));
    }
    await loader.load();
  });

  Future<void> pumpScreen(
      WidgetTester tester, Widget screen, AppDependencies deps) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1400);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        appProviders(screen, dependencies: deps, theme: AppTheme.light));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 600));
    }
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  }

  group('home', () {
    testWidgets("shows today's meals and foods from the plan", (tester) async {
      final deps = AppDependencies.inMemory(
          mealPlanSource: FakeMealPlanSource(samplePlanJson()));
      await pumpScreen(tester, const HomeDashboardScreen(), deps);

      expect(find.text(ar.mealTypeBreakfast), findsOneWidget);
      expect(find.text(ar.mealTypeLunch), findsOneWidget);
      expect(find.text(ar.mealTypeDinner), findsOneWidget);
      expect(find.text(ar.mealTypeSnack), findsOneWidget,
          reason: "today's day-specific snack");
      expect(find.text('بيض مسلوق'), findsOneWidget);
      expect(find.text(ar.homeMealsLogged(0, 4)), findsOneWidget);
      // None of the old demo content.
      expect(find.text(ar.homeItemTwoBoiledEggs), findsNothing);
      await unmount(tester);
    });

    testWidgets('no active plan (204) is an empty state, not an error',
        (tester) async {
      final deps =
          AppDependencies.inMemory(mealPlanSource: FakeMealPlanSource());
      await pumpScreen(tester, const HomeDashboardScreen(), deps);

      expect(find.text(ar.planEmptyTitle), findsOneWidget);
      expect(find.text(ar.commonRetry), findsNothing);
      await unmount(tester);
    });

    testWidgets('a failed read offers a retry that shows the plan',
        (tester) async {
      final source = FakeMealPlanSource(samplePlanJson())
        ..error = const ServerException('down', statusCode: 500);
      final deps = AppDependencies.inMemory(mealPlanSource: source);
      await pumpScreen(tester, const HomeDashboardScreen(), deps);
      expect(find.text(ar.commonRetry), findsOneWidget);

      source.error = null;
      await tester.tap(find.text(ar.commonRetry));
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 600));
      }

      expect(find.text('بيض مسلوق'), findsOneWidget);
      await unmount(tester);
    });
  });

  testWidgets('meal detail logs the alternative the patient picked',
      (tester) async {
    final deps = AppDependencies.inMemory(
        mealPlanSource: FakeMealPlanSource(samplePlanJson()));
    await pumpScreen(tester, MealDetailScreen(meal: sampleLunch()), deps);

    // Swap the chicken for the fish fillet the nutritionist allowed.
    await tester.tap(find.text('سمك فيليه'));
    await tester.pump(const Duration(milliseconds: 300));
    final logButton = find.text(ar.mealDetailLoggedNow);
    await tester.ensureVisible(logButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(logButton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final entries = BlocProvider.of<MealLogCubit>(
            tester.element(find.byType(Navigator).first))
        .state
        .entries;
    // Fish 192 + rice 134 + salad 40, not the planned 422. (The POST bodies,
    // with each item's meal_item_id, are checked in meal_log_repository_test.)
    expect(entries.single.calories, 366);
    expect(entries.single.plannedMeal?.id, '22');
    await unmount(tester);
  });
}
