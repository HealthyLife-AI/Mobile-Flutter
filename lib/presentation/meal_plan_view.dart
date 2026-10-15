import 'package:flutter/widgets.dart';

import '../core/time/date_only.dart';
import '../domain/entities/meal_entities.dart';
import '../domain/entities/meal_plan_entities.dart';
import '../l10n/l10n.dart';

/// What the screens show of the nutritionist's plan (API guide 5.1).
///
/// The API sends no meal times, so a meal shows its name only. Only today's
/// meals track logs: on any other day every meal is upcoming.

String planMealName(AppLocalizations l10n, PlanMealType type) => switch (type) {
      PlanMealType.breakfast => l10n.mealTypeBreakfast,
      PlanMealType.lunch => l10n.mealTypeLunch,
      PlanMealType.dinner => l10n.mealTypeDinner,
      PlanMealType.snack => l10n.mealTypeSnack,
      PlanMealType.other => l10n.mealTypeOther,
    };

/// The `MealCard` icon slot for a meal type.
String _iconSlot(PlanMealType type) => switch (type) {
      PlanMealType.breakfast => 'sun',
      PlanMealType.lunch => 'sun_orange',
      PlanMealType.snack => 'leaf',
      PlanMealType.dinner => 'moon',
      PlanMealType.other => '',
    };

/// The label under a food: its main macro, from the code `FoodDto` picks.
String macroLabelFor(AppLocalizations l10n, String macro) => switch (macro) {
      'protein' => l10n.macroProteinLabel,
      'carbs' => l10n.macroCarbohydrates,
      'fat' => l10n.macroFatLabel,
      _ => '',
    };

/// The day's meals, in the plan's order. Today, a meal [isLogged] is
/// `logged`, the first one not logged is `current` and the rest `upcoming`.
List<Meal> planMealsFor(BuildContext context, MealPlan plan, DateTime day,
    {bool Function(String mealId)? isLogged}) {
  final l10n = context.l10n;
  final isToday = isSameLocalDay(day, DateTime.now());
  var currentGiven = false;
  final meals = <Meal>[];
  for (final source in plan.mealsOn(day)) {
    final id = '${source.id}';
    final MealStatus status;
    if (isToday && (isLogged?.call(id) ?? false)) {
      status = MealStatus.logged;
    } else if (isToday && !currentGiven) {
      status = MealStatus.current;
      currentGiven = true;
    } else {
      status = MealStatus.upcoming;
    }
    meals.add(Meal(
      id: id,
      name: planMealName(l10n, source.type),
      timeRange: '',
      calories: source.macros.calories.round(),
      items: [
        for (final item in source.items)
          MealItem(name: item.food.name, grams: item.quantityGrams),
      ],
      alternativesText: suggestedAlternative(context, source) ?? '',
      status: status,
      iconEmojiSlot: _iconSlot(source.type),
      source: source,
    ));
  }
  return meals;
}

/// "Suggested alternative: …" for the meal's first alternative, or null when
/// the nutritionist allowed none.
String? suggestedAlternative(BuildContext context, PlanMeal meal) {
  for (final item in meal.items) {
    if (item.alternatives.isEmpty) continue;
    final alt = item.alternatives.first;
    return context.l10n.homeSuggestedAlternative(
        alt.food.name, context.localizeDigits(alt.quantityGrams));
  }
  return null;
}

/// One swap group per planned item: the item itself, then its alternatives
/// (5.1). Each option keeps its plan item, so the one picked is what's logged.
List<FoodCategoryGroup> planSwapGroups(BuildContext context, PlanMeal meal) {
  final l10n = context.l10n;
  FoodOption option(PlanItem item, {bool original = false}) => FoodOption(
        name: item.food.name,
        grams: item.quantityGrams,
        calories: item.macros.calories.round(),
        macroLabel: macroLabelFor(l10n, item.food.macro),
        isOriginal: original,
        macro: item.food.macro,
        planItem: item,
      );
  return [
    for (final item in meal.items)
      FoodCategoryGroup(title: item.food.name, options: [
        option(item, original: true),
        for (final alt in item.alternatives) option(alt),
      ]),
  ];
}
