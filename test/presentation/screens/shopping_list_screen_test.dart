import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/theme/app_theme.dart';
import 'package:healthylife_ai/presentation/screens/shopping_list_screen.dart';
import 'package:healthylife_ai/presentation/screens/weekly_plan_screen.dart';

import '../../helpers/app_font.dart';
import '../../helpers/app_providers.dart';

void main() {
  setUpAll(() async {
    expect(await loadAppFont(), isTrue);
  });

  testWidgets('the weekly plan opens the shopping list (5.4)', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 2600);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        appProviders(const WeeklyPlanScreen(), theme: AppTheme.light));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byTooltip('قائمة التسوق'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(ShoppingListScreen), findsOneWidget);

    // Today: one lunch's chicken, with its alternative listed under it.
    expect(find.text('لحوم ودواجن وأسماك'), findsOneWidget);
    expect(find.text('صدر دجاج مشوي'), findsOneWidget);
    expect(find.text('أو: سمك فيليه'), findsOneWidget);
    expect(find.text('60 غرام'), findsOneWidget, reason: 'the oat bread');

    // The week: the daily bread seven times, today's snack apple once.
    await tester.tap(find.text('الأسبوع كاملًا'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('420 غرام'), findsOneWidget);
    expect(find.text('180 غرام'), findsOneWidget);
  });
}
