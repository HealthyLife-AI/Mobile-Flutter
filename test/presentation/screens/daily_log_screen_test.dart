import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/di/app_dependencies.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/theme/app_theme.dart';
import 'package:healthylife_ai/domain/entities/meal_entities.dart';
import 'package:healthylife_ai/presentation/bloc/meal_log/meal_log_cubit.dart';
import 'package:healthylife_ai/presentation/screens/daily_log_screen.dart';

import '../../helpers/app_font.dart';
import '../../helpers/app_providers.dart';
import '../../helpers/sample_meal_plan.dart';
import '../../helpers/scripted_api.dart';

const SearchableFood _dates =
    SearchableFood(name: 'تمر', caloriesPer100g: 280, macro: 'carb', id: 3);

void main() {
  setUpAll(() async {
    expect(await loadAppFont(), isTrue);
  });

  /// Today's log holds one food the server saved as log 501, and the screen
  /// shows it.
  Future<(ScriptedApi, AppDependencies)> open(WidgetTester tester,
      {Object? deleteAnswer}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 2400);
    addTearDown(tester.view.reset);
    final api = ScriptedApi({
      'POST me/meal-logs': {
        'id': 501,
        'editable_until': DateTime.now()
            .toUtc()
            .add(const Duration(days: 7))
            .toIso8601String(),
      },
      'DELETE me/meal-logs/501': deleteAnswer,
    });
    final deps = AppDependencies.inMemory(
      api: api,
      mealPlanSource: FakeMealPlanSource(samplePlanJson()),
    );
    await deps.mealLog.logFood(_dates, grams: 100);
    await tester.pumpWidget(appProviders(
      const DailyLogScreen(),
      dependencies: deps,
      theme: AppTheme.light,
    ));
    await tester
        .element(find.byType(DailyLogScreen))
        .read<MealLogCubit>()
        .load();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('تمر'), findsOneWidget);
    return (api, deps);
  }

  Future<void> deleteAndWait(WidgetTester tester) async {
    await tester.tap(find.byTooltip('حذف الوجبة'));
    await tester.pump();
    // The undo notice stays 4 seconds and slides away, then the delete is
    // sent. Pumped a second at a time, so the exit animation runs.
    for (var i = 0; i < 7; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
  }

  testWidgets('delete removes the log on the server (6.4)', (tester) async {
    final (api, deps) = await open(tester);

    await deleteAndWait(tester);

    expect(api.to('DELETE', 'me/meal-logs/501'), hasLength(1));
    final left = await deps.mealLog.getEntries();
    expect(left.valueOrNull, isEmpty);
  });

  testWidgets('undo keeps the meal and sends no delete', (tester) async {
    final (api, _) = await open(tester);

    await tester.tap(find.byTooltip('حذف الوجبة'));
    await tester.pump(const Duration(milliseconds: 500));
    // What the notice's undo button does when pressed.
    tester.widget<SnackBarAction>(find.byType(SnackBarAction)).onPressed();
    ScaffoldMessenger.of(tester.element(find.byType(DailyLogScreen)))
        .hideCurrentSnackBar(reason: SnackBarClosedReason.action);
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(seconds: 1));
    }

    expect(api.to('DELETE', 'me/meal-logs/501'), isEmpty);
    expect(find.text('تمر'), findsOneWidget);
  });

  testWidgets('offline, the meal comes back and the patient is told',
      (tester) async {
    final (_, _) = await open(tester,
        deleteAnswer: const NetworkException('offline',
            kind: NetworkFailureKind.offline));

    await deleteAndWait(tester);

    expect(find.textContaining('الحذف يحتاج اتصالًا'), findsOneWidget);
    expect(find.text('تمر'), findsOneWidget);
  });

  /// A log object as the server answers (6.1), eaten now.
  Map<String, dynamic> serverLog(int id, String food,
          {int grams = 100, double calories = 280}) =>
      {
        'id': id,
        'food': {'id': 3, 'name_ar': food, 'name_en': 'Dates'},
        'quantity_grams': grams,
        'macros': {'calories': calories},
        'meal_item_id': null,
        'log_kind': 'off_plan',
        'logged_at': DateTime.now().toUtc().toIso8601String(),
        'editable_until': DateTime.now()
            .toUtc()
            .add(const Duration(days: 7))
            .toIso8601String(),
      };

  Map<String, dynamic> page(List<Map<String, dynamic>> logs) => {
        'data': logs,
        'meta': {'current_page': 1, 'last_page': 1},
      };

  /// Lets the grams sheet slide all the way in.
  Future<void> openSheet(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  testWidgets('a log made on another device shows here (6.2)', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 2400);
    addTearDown(tester.view.reset);
    final api = ScriptedApi({
      'GET me/meal-logs': page([serverLog(900, 'لوز')]),
    });
    await tester.pumpWidget(appProviders(
      const DailyLogScreen(),
      dependencies: AppDependencies.inMemory(
        api: api,
        mealPlanSource: FakeMealPlanSource(samplePlanJson()),
      ),
      theme: AppTheme.light,
    ));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    expect(api.to('GET', 'me/meal-logs'), hasLength(1));
    expect(find.text('لوز'), findsOneWidget);
  });

  testWidgets('tapping a food changes its grams on the server (6.3)',
      (tester) async {
    final (api, _) = await open(tester);
    api.routes['GET me/meal-logs'] = page([serverLog(501, 'تمر')]);
    api.routes['PATCH me/meal-logs/501'] =
        serverLog(501, 'تمر', grams: 180, calories: 504);

    await tester.tap(find.text('تمر'));
    await openSheet(tester);
    await tester.enterText(find.byType(TextField), '180');
    await tester.tap(find.text('حفظ'));
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }

    expect(api.to('PATCH', 'me/meal-logs/501').single.body,
        {'quantity_grams': 180});
    expect(find.text('تم تعديل الكمية'), findsOneWidget);
  });

  testWidgets('grams outside 1 to 5000 are not sent', (tester) async {
    final (api, _) = await open(tester);

    await tester.tap(find.text('تمر'));
    await openSheet(tester);
    await tester.enterText(find.byType(TextField), '9000');
    await tester.tap(find.text('حفظ'));
    await tester.pump();

    expect(find.text('أدخل كمية بين 1 و5000 غرام.'), findsOneWidget);
    expect(api.to('PATCH', 'me/meal-logs/501'), isEmpty);
  });
}
