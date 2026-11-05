import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/domain/shopping_list.dart';

import '../helpers/sample_meal_plan.dart';

void main() {
  final today = DateTime(2026, 10, 7); // a Wednesday
  final plan = samplePlan(today: today);

  /// Grams by food name, over every section.
  Map<String, int> gramsOf(List<ShoppingSection> sections) => {
        for (final section in sections)
          for (final item in section.items) item.food.name: item.grams,
      };

  test('one day is the daily meals plus that weekday\'s meals (5.4)', () {
    final grams = gramsOf(shoppingListFor(plan, day: today));

    expect(grams['صدر دجاج مشوي'], 150);
    expect(grams['تفاحة'], 180, reason: "the snack is on today's weekday");
    expect(grams.containsKey('سمك فيليه'), isFalse,
        reason: 'an alternative is not bought');

    final tomorrow = gramsOf(
        shoppingListFor(plan, day: today.add(const Duration(days: 1))));
    expect(tomorrow.containsKey('تفاحة'), isFalse);
  });

  test('a week is the daily meals seven times, the day meals once', () {
    final grams = gramsOf(shoppingListFor(plan));

    expect(grams['صدر دجاج مشوي'], 150 * 7);
    expect(grams['زبادي يوناني'], 150 * 7);
    expect(grams['تفاحة'], 180);
  });

  test('sections follow the guide\'s order, empty ones left out', () {
    final sections = shoppingListFor(plan, day: today);

    expect(sections.map((s) => s.key), [
      'produce',
      'meat_poultry_fish',
      'dairy_eggs',
      'grains_starches',
    ]);
  });

  test('alternatives are listed under the item they replace', () {
    final meat = shoppingListFor(plan, day: today)
        .firstWhere((s) => s.key == 'meat_poultry_fish');

    final chicken = meat.items.single;
    expect(chicken.alternatives.map((f) => f.name), ['سمك فيليه']);
  });
}
