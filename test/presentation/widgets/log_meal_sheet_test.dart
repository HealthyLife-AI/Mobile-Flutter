import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/di/app_dependencies.dart';
import 'package:healthylife_ai/core/theme/app_theme.dart';
import 'package:healthylife_ai/l10n/l10n.dart';
import 'package:healthylife_ai/presentation/app_shell.dart';
import 'package:healthylife_ai/presentation/screens/food_search_screen.dart';
import 'package:healthylife_ai/presentation/screens/meal_detail_screen.dart';
import 'package:healthylife_ai/presentation/widgets/log_meal_sheet.dart';

import '../../helpers/app_font.dart';
import '../../helpers/app_providers.dart';
import '../../helpers/sample_meal_plan.dart';
import '../../helpers/scripted_api.dart';

/// "Log a meal" is a bottom sheet over the current screen, not a screen of its
/// own: a meal from the plan in one tap, or a food that is not in the plan.
void main() {
  final ar = lookupAppLocalizations(const Locale('ar'));

  setUpAll(() async {
    expect(await loadAppFont(), isTrue);
  });

  Map<String, Object?> saved() => {
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

  Future<ScriptedApi> openSheet(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1800);
    addTearDown(tester.view.reset);
    final api = ScriptedApi({
      'POST me/meal-logs': (SentRequest _) => saved(),
      'GET me/meal-logs': {
        'data': <Object>[],
        'meta': {'current_page': 1, 'last_page': 1}
      },
    });
    final deps = AppDependencies.inMemory(
        mealPlanSource: FakeMealPlanSource(samplePlanJson()), api: api);
    await tester.pumpWidget(appProviders(
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => showLogMealSheet(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      dependencies: deps,
      theme: AppTheme.light,
    ));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('open'));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    return api;
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 8));
  }

  testWidgets('shows both tabs and today\'s meals from the plan',
      (tester) async {
    await openSheet(tester);

    expect(find.byType(LogMealSheet), findsOneWidget);
    expect(find.text(ar.logMealTitle), findsOneWidget);
    expect(find.text(ar.logMealTabPlan), findsOneWidget);
    expect(find.text(ar.logMealTabOffPlan), findsOneWidget);
    // Breakfast, lunch and dinner of the sample plan (and today's snack),
    // each with its own one-tap button.
    expect(find.text(ar.mealAte), findsAtLeastNWidgets(3));
    await unmount(tester);
  });

  testWidgets('«أكلتها» on a row logs that meal, closes the sheet and confirms',
      (tester) async {
    final api = await openSheet(tester);

    await tester.tap(find.text(ar.mealAte).first);
    await tester.pump();
    for (var i = 0; i < 40 && find.text(ar.mealUndo).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(api.to('POST', 'me/meal-logs'), isNotEmpty);
    expect(find.byType(LogMealSheet), findsNothing);
    expect(find.text(ar.mealUndo), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('a row opens the meal\'s details', (tester) async {
    await openSheet(tester);

    await tester.tap(find.textContaining(ar.commonCaloriesValue(330)).first);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }

    expect(find.byType(LogMealSheet), findsNothing);
    expect(find.byType(MealDetailScreen), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('the off-plan tab leads to the food search', (tester) async {
    await openSheet(tester);

    await tester.tap(find.text(ar.logMealTabOffPlan));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.text(ar.logMealSearchFood), findsOneWidget);
    expect(find.text(ar.mealAte), findsNothing);

    await tester.tap(find.text(ar.logMealSearchFood));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }

    expect(find.byType(LogMealSheet), findsNothing);
    expect(find.byType(FoodSearchScreen), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('the close button is 48dp and closes the sheet', (tester) async {
    await openSheet(tester);

    final close = find.byTooltip(ar.commonClose);
    expect(tester.getSize(close).height, greaterThanOrEqualTo(48));
    await tester.tap(close);
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }

    expect(find.byType(LogMealSheet), findsNothing);
    await unmount(tester);
  });

  testWidgets('the + button of the app opens the sheet, not a screen',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1800);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(appProviders(const AppShell(),
        dependencies: AppDependencies.inMemory(
            mealPlanSource: FakeMealPlanSource(samplePlanJson()),
            api: ScriptedApi()),
        theme: AppTheme.light));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byTooltip(ar.navLogMealTooltip));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }

    expect(find.byType(LogMealSheet), findsOneWidget);
    expect(find.byType(AppShell), findsOneWidget,
        reason: 'the shell is still there beneath the sheet');
    await unmount(tester);
  });
}
