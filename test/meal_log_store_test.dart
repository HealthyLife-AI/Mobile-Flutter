import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/data/mock/meal_mock_data.dart';
import 'package:healthylife_ai/data/repositories/meal_log_store.dart';
import 'package:healthylife_ai/domain/entities/meal_entities.dart';

void main() {
  test('records planned and off-plan meals without duplicating a plan entry', () {
    final store = MealLogStore.instance;
    const food = SearchableFood(name: 'موز مسجل للاختبار', caloriesPer100g: 89, macro: 'carbs');
    final initialCount = store.entries.length;
    final offPlanEntry = store.recordFood(food, 150);
    final plannedMeal = MockData.todayMeals.firstWhere((meal) => meal.id == 'lunch');
    final plannedEntry = store.recordPlanned(plannedMeal);

    expect(offPlanEntry.calories, 134);
    expect(offPlanEntry.grams, 150);
    expect(offPlanEntry.isOffPlan, isTrue);
    expect(plannedEntry.plannedMeal?.id, 'lunch');
    expect(store.recordPlanned(plannedMeal).id, plannedEntry.id);
    expect(store.entries.length, initialCount + 2);
  });

}