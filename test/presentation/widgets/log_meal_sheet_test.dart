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

  Future<void> pick(WidgetTester tester, int kcal) async {
    await tester.tap(find.textContaining(ar.commonCaloriesValue(kcal)).first);
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  bool ticked(WidgetTester tester, String food) => tester
      .widget<Checkbox>(find.descendant(
          of: find.ancestor(
              of: find.text(food), matching: find.byType(Material)).first,
          matching: find.byType(Checkbox)))
      .value!;

  testWidgets('a row shows the meal\'s foods, all ticked, and one log button',
      (tester) async {
    await openSheet(tester);
    await pick(tester, 330);

    expect(find.byType(LogMealSheet), findsOneWidget);
    expect(find.text(ar.logSheetUncheckHint), findsOneWidget);
    expect(ticked(tester, 'بيض مسلوق'), isTrue);
    expect(ticked(tester, 'خبز شوفان'), isTrue);
    expect(find.text(ar.logSheetLogMeal(ar.mealTypeBreakfast, '330')),
        findsOneWidget);
    // Back to the list, where «أكلتها» stays the quick path.
    await tester.tap(find.text(ar.logSheetChangeMeal));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(ar.mealAte), findsAtLeastNWidgets(3));
    await unmount(tester);
  });

  testWidgets('the details and alternatives are one more tap away',
      (tester) async {
    await openSheet(tester);
    await pick(tester, 330);
    await tester.tap(find.text(ar.mealDetailsAndSwaps));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.byType(LogMealSheet), findsNothing);
    expect(find.byType(MealDetailScreen), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('an unticked food is not logged, and the total follows',
      (tester) async {
    final api = await openSheet(tester);
    await pick(tester, 330);

    await tester.tap(find.descendant(
        of: find.ancestor(
            of: find.text('خبز شوفان'), matching: find.byType(Material)).first,
        matching: find.byType(Checkbox)));
    await tester.pump();
    final button = find.text(ar.logSheetLogMeal(ar.mealTypeBreakfast, '155'));
    expect(button, findsOneWidget);

    await tester.tap(button);
    for (var i = 0; i < 40 && find.text(ar.mealUndo).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    // One log per food eaten (6.1): the egg only.
    final posts = api.to('POST', 'me/meal-logs');
    expect(posts, hasLength(1));
    expect((posts.single.body as Map)['meal_item_id'], 55);
    // Let the sheet finish closing.
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.byType(LogMealSheet), findsNothing);
    expect(find.text(ar.mealUndo), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('«تبديل إلى» swaps a food for its alternative and back',
      (tester) async {
    await openSheet(tester);
    await pick(tester, 330);

    await tester.tap(find.text(ar.logSheetSwapTo('جبنة قريش')));
    await tester.pump();
    expect(find.text('جبنة قريش'), findsOneWidget);
    expect(find.text('بيض مسلوق'), findsNothing);
    expect(find.text(ar.logSheetLogMeal(ar.mealTypeBreakfast, '273')),
        findsOneWidget);

    await tester.tap(find.text(ar.logSheetSwapTo('بيض مسلوق')));
    await tester.pump();
    expect(find.text('بيض مسلوق'), findsOneWidget);
    expect(find.text(ar.logSheetLogMeal(ar.mealTypeBreakfast, '330')),
        findsOneWidget);
    await unmount(tester);
  });

  testWidgets('a swapped food is what gets logged', (tester) async {
    final api = await openSheet(tester);
    await pick(tester, 330);
    await tester.tap(find.text(ar.logSheetSwapTo('جبنة قريش')));
    await tester.pump();
    await tester.tap(find.text(ar.logSheetLogMeal(ar.mealTypeBreakfast, '273')));
    for (var i = 0; i < 40 && find.text(ar.mealUndo).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final ids = [
      for (final r in api.to('POST', 'me/meal-logs'))
        (r.body as Map)['meal_item_id'],
    ];
    // The cottage cheese (56) in place of the egg (55), and the bread.
    expect(ids, contains(56));
    expect(ids, isNot(contains(55)));
    expect(ids, hasLength(2));
    await unmount(tester);
  });

  testWidgets('with nothing ticked there is nothing to log', (tester) async {
    await openSheet(tester);
    await pick(tester, 330);
    for (final food in ['بيض مسلوق', 'خبز شوفان']) {
      await tester.tap(find.descendant(
          of: find.ancestor(of: find.text(food), matching: find.byType(Material))
              .first,
          matching: find.byType(Checkbox)));
      await tester.pump();
    }
    final button = tester.widget<ButtonStyleButton>(find.ancestor(
        of: find.text(ar.logSheetLogMeal(ar.mealTypeBreakfast, '0')),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton)));
    expect(button.onPressed, isNull);
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

  testWidgets('the foods step fits a 360dp phone with a large font',
      (tester) async {
    await openSheet(tester);
    tester.view.physicalSize = const Size(360, 800);
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pump(const Duration(milliseconds: 300));
    await pick(tester, 422);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });
}
