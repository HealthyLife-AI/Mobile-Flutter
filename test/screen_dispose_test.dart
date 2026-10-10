import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:healthylife_ai/presentation/screens/food_search_screen.dart';
import 'package:healthylife_ai/presentation/screens/home_dashboard_screen.dart';
import 'package:healthylife_ai/presentation/screens/meal_log_success_screen.dart';
import 'package:healthylife_ai/presentation/screens/new_measurement_screen.dart';
import 'package:healthylife_ai/presentation/screens/notifications_center_screen.dart';
import 'package:healthylife_ai/presentation/screens/plan_preparing_screen.dart';
import 'package:healthylife_ai/presentation/screens/progress_screen.dart';

/// Guards against `late final AnimationController` fields that are constructed
/// from `dispose()`: the constructor looks up the TickerMode ancestor of an
/// element that is already deactivated and throws "Looking up a deactivated
/// widget's ancestor is unsafe".
void main() {
  final screens = <String, Widget Function()>{
    'food search': () => const FoodSearchScreen(),
    'home dashboard': () => const HomeDashboardScreen(),
    'notifications center': () => const NotificationsCenterScreen(),
    'measurement entry': () => const MeasurementEntryScreen(),
    'plan preparing': () => const PlanPreparingScreen(),
    'progress': () => const ProgressScreen(),
    'meal log success': () => const MealLogSuccessScreen(),
  };

  for (final entry in screens.entries) {
    testWidgets('${entry.key} screen disposes cleanly', (tester) async {
      await tester.pumpWidget(MaterialApp(home: entry.value()));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 1));

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      expect(tester.takeException(), isNull);
    });
  }
}
