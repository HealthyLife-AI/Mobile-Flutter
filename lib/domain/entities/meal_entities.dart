/// Domain entities for meals, foods and log entries.
///
/// Mirrors the shapes of the planned `/me/meal-plan` and `/foods/search`
/// API responses (see the "Mobile API Reference" doc, section 3.1). Pure
/// Dart â€” no Flutter imports, no mock data.

class MealItem {
  final String name;
  final int grams;
  final bool checked;
  const MealItem({required this.name, required this.grams, this.checked = false});
}

class Meal {
  final String id;
  final String name;
  final String timeRange;
  final int calories;
  final List<MealItem> items;
  final String alternativesText;
  final MealStatus status;
  final String iconEmojiSlot;

  const Meal({
    required this.id,
    required this.name,
    required this.timeRange,
    required this.calories,
    required this.items,
    required this.alternativesText,
    required this.status,
    required this.iconEmojiSlot,
  });
}

enum MealStatus { logged, current, upcoming }

class MealLogEntry {
  final String id;
  final String name;
  final int calories;
  final int grams;
  final DateTime loggedAt;
  final bool isOffPlan;
  final Meal? plannedMeal;

  const MealLogEntry({
    required this.id,
    required this.name,
    required this.calories,
    required this.grams,
    required this.loggedAt,
    required this.isOffPlan,
    this.plannedMeal,
  });
}

class FoodOption {
  final String name;
  final int grams;
  final int calories;
  final String macroLabel;
  final bool isOriginal;
  final bool selected;
  final bool locked;

  const FoodOption({
    required this.name,
    required this.grams,
    required this.calories,
    required this.macroLabel,
    this.isOriginal = false,
    this.selected = false,
    this.locked = false,
  });
}

class FoodCategoryGroup {
  final String title;
  final List<FoodOption> options;
  const FoodCategoryGroup({required this.title, required this.options});
}

class SearchableFood {
  final String name;
  final int caloriesPer100g;
  final String macro;
  // FoodTagColorMapper (2.3) key: redFruit | greenFruit | naturalSugar |
  // dairy | cookedProtein | carb | nuts — a category system, NOT the
  // literal food name, and deliberately separate from mealType colors.
  final String category;
  const SearchableFood({required this.name, required this.caloriesPer100g, required this.macro, this.category = 'default'});
}

