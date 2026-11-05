/// The shopping list, built on the device from the plan (API guide 5.4).
///
/// Only planned items are bought; each item's alternatives are listed under
/// it as «أو». One day is the daily meals plus that weekday's meals. A week is
/// the daily meals seven times, plus each day-specific meal once. Grams are
/// added up per food, then grouped by the food's shopping section.
library;

import 'entities/meal_entities.dart';
import 'entities/meal_plan_entities.dart';

/// The sections, in the order the list shows them (5.4). A food with no
/// section, or one this version does not know, goes under `other`.
const List<String> shoppingSections = [
  'produce',
  'meat_poultry_fish',
  'dairy_eggs',
  'grains_starches',
  'legumes_nuts',
  'oils_spices',
  'other',
];

/// One food to buy, and how much.
class ShoppingItem {
  const ShoppingItem({
    required this.food,
    required this.grams,
    this.alternatives = const [],
  });

  final SearchableFood food;

  /// Every planned portion of [food] in the period, added up.
  final int grams;

  /// Foods the plan allows instead, each once.
  final List<SearchableFood> alternatives;
}

/// One aisle of the list.
class ShoppingSection {
  const ShoppingSection({required this.key, required this.items});

  /// One of [shoppingSections].
  final String key;
  final List<ShoppingItem> items;
}

/// The list for [day], or for the whole week when [day] is null. Sections
/// with nothing to buy are left out; items keep the plan's order.
List<ShoppingSection> shoppingListFor(MealPlan plan, {DateTime? day}) {
  final grams = <Object, int>{};
  final foods = <Object, SearchableFood>{};
  final alternatives = <Object, Map<Object, SearchableFood>>{};

  final meals = day == null ? plan.meals : plan.mealsOn(day);
  for (final meal in meals) {
    // A meal that repeats every day is eaten seven times in a week.
    final times = day == null && meal.dayIndex == null ? 7 : 1;
    for (final item in meal.items) {
      final key = _keyOf(item.food);
      foods.putIfAbsent(key, () => item.food);
      grams[key] = (grams[key] ?? 0) + item.quantityGrams * times;
      final others = alternatives.putIfAbsent(key, () => {});
      for (final alternative in item.alternatives) {
        final otherKey = _keyOf(alternative.food);
        if (otherKey != key) others.putIfAbsent(otherKey, () => alternative.food);
      }
    }
  }

  final bySection = <String, List<ShoppingItem>>{};
  for (final MapEntry(:key, value: food) in foods.entries) {
    final section = shoppingSections.contains(food.shoppingSection)
        ? food.shoppingSection!
        : 'other';
    bySection.putIfAbsent(section, () => []).add(ShoppingItem(
          food: food,
          grams: grams[key]!,
          alternatives: alternatives[key]!.values.toList(),
        ));
  }
  return [
    for (final section in shoppingSections)
      if (bySection[section] case final items?)
        ShoppingSection(key: section, items: items),
  ];
}

/// The same food on every item: its server id, or its name without one.
Object _keyOf(SearchableFood food) => food.id ?? food.name;
