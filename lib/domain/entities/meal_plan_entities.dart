/// The patient's active meal plan from `GET /me/meal-plan` (API guide 5.1).
///
/// Pure Dart: no Flutter imports, no wire format.
library;

import 'meal_entities.dart';

/// `meals[].name` on the wire. [other] keeps a meal the app does not know
/// yet instead of dropping it.
enum PlanMealType { breakfast, snack, lunch, dinner, other }

/// `{calories, protein_g, carbs_g, fat_g}` (5.1).
class Macros {
  const Macros({
    this.calories = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
  });

  static const Macros zero = Macros();

  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  Macros operator +(Macros other) => Macros(
        calories: calories + other.calories,
        proteinG: proteinG + other.proteinG,
        carbsG: carbsG + other.carbsG,
        fatG: fatG + other.fatG,
      );
}

/// One planned food, or one of its alternatives. Its [id] is the
/// `meal_item_id` a log of it carries (6.1). The nutritionist swapping a food
/// gives the item a new id, so ids are never kept across plan reads.
class PlanItem {
  const PlanItem({
    required this.id,
    required this.food,
    required this.quantityGrams,
    required this.macros,
    this.alternatives = const [],
  });

  final int id;

  /// The food object (5.2). Always has a server id, since a log needs one.
  final SearchableFood food;
  final int quantityGrams;

  /// For an alternative: the values "if you eat this instead" (5.1).
  final Macros macros;
  final List<PlanItem> alternatives;
}

class PlanMeal {
  const PlanMeal({
    required this.id,
    required this.type,
    required this.macros,
    required this.items,
    this.dayIndex,
  });

  final int id;
  final PlanMealType type;

  /// Null: the meal repeats every day. 0–6: Monday–Sunday (5.1).
  final int? dayIndex;

  /// Planned items only; alternatives are not counted (5.1).
  final Macros macros;
  final List<PlanItem> items;

  bool isOn(DateTime day) => dayIndex == null || dayIndex == dayIndexOf(day);

  /// The plan's day index for [day]. Dart counts Monday as 1, the plan as 0.
  static int dayIndexOf(DateTime day) => day.weekday - 1;
}

class MealPlan {
  const MealPlan({
    required this.id,
    required this.meals,
    this.startDate,
    this.summaryByDay = const {},
  });

  final int id;

  /// The plan's first day, when the server sends one.
  final DateTime? startDate;

  /// In the order the nutritionist arranged them.
  final List<PlanMeal> meals;

  /// Planned totals per day index (0–6), as the server summed them.
  final Map<int, Macros> summaryByDay;

  /// A day's menu: the daily meals plus that weekday's meals (5.1).
  List<PlanMeal> mealsOn(DateTime day) => [
        for (final meal in meals)
          if (meal.isOn(day)) meal
      ];

  /// The day's planned totals. Uses the server's summary, and adds up the
  /// day's meals when the summary has no entry for that day.
  Macros totalOn(DateTime day) =>
      summaryByDay[PlanMeal.dayIndexOf(day)] ??
      mealsOn(day).fold(Macros.zero, (total, meal) => total + meal.macros);
}
