/// Domain entities for meals, foods and log entries.
///
/// [Meal] is what the screens show for one meal of the day. Built from the
/// active plan (`meal_plan_entities.dart`), it keeps its [Meal.source] so a log
/// can name the plan items that were eaten (API guide 6.1). Pure Dart — no
/// Flutter imports, no mock data.
library;

import 'meal_plan_entities.dart';

class MealItem {
  final String name;
  final int grams;
  final bool checked;
  const MealItem(
      {required this.name, required this.grams, this.checked = false});
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

  /// The plan meal this was built from, or null for a meal that is not from
  /// the server's plan (for example one restored from an older log).
  final PlanMeal? source;

  const Meal({
    required this.id,
    required this.name,
    required this.timeRange,
    required this.calories,
    required this.items,
    required this.alternativesText,
    required this.status,
    required this.iconEmojiSlot,
    this.source,
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

<<<<<<< HEAD
  /// The logs this entry was sent to the server as (6.1): one per food eaten.
  /// Empty for an entry that never went to the server.
  final List<SentMealLog> sentLogs;

=======
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
  const MealLogEntry({
    required this.id,
    required this.name,
    required this.calories,
    required this.grams,
    required this.loggedAt,
    required this.isOffPlan,
    this.plannedMeal,
<<<<<<< HEAD
    this.sentLogs = const [],
  });

  /// False once the server's edit window has passed for one of its logs
  /// (6.1: show delete only before `editable_until`).
  bool canDeleteAt(DateTime now) => sentLogs.every((log) {
        final until = log.editableUntil;
        return until == null || now.isBefore(until);
      });

  /// Whether its grams can be changed now (6.3): one food the server has
  /// saved, still inside the edit window. A plan meal holds several logs, so
  /// it has no single amount to change.
  bool canEditGramsAt(DateTime now) =>
      plannedMeal == null &&
      sentLogs.length == 1 &&
      sentLogs.single.serverId != null &&
      canDeleteAt(now);

  MealLogEntry copyWith({
    int? calories,
    int? grams,
    List<SentMealLog>? sentLogs,
  }) =>
      MealLogEntry(
        id: id,
        name: name,
        calories: calories ?? this.calories,
        grams: grams ?? this.grams,
        loggedAt: loggedAt,
        isOffPlan: isOffPlan,
        plannedMeal: plannedMeal,
        sentLogs: sentLogs ?? this.sentLogs,
      );
}

/// One `POST /me/meal-logs` made for a [MealLogEntry].
class SentMealLog {
  const SentMealLog({required this.key, this.serverId, this.editableUntil});

  /// The idempotency key the log was sent with. It finds the write in the
  /// offline queue, and the server's answer to it.
  final String key;

  /// The server's id for the log, once it has been saved. Null while the
  /// write waits in the queue, or when the server refused it.
  final int? serverId;

  /// `editable_until` from the server's answer: until then the log can be
  /// deleted.
  final DateTime? editableUntil;
=======
  });
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
}

class FoodOption {
  final String name;
  final int grams;
  final int calories;
  final String macroLabel;
  final bool isOriginal;
  final bool selected;
  final bool locked;

  /// The dominant macro code (`protein`, `carbs`, `fat`, `default`) for the
  /// option's icon, independent of the display language. Empty when unknown.
  final String macro;

  /// The plan item (or alternative) this option stands for; logged when the
  /// patient picks it (API guide 6.1). Null for an option not from the plan.
  final PlanItem? planItem;

  const FoodOption({
    required this.name,
    required this.grams,
    required this.calories,
    required this.macroLabel,
    this.isOriginal = false,
    this.selected = false,
    this.locked = false,
    this.macro = '',
    this.planItem,
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

  /// The food's id on the server (API guide 5.2). A log needs one, so a food
  /// the app makes up (a manual estimate) has none.
  final int? id;

  /// The allergen groups the server tags the food with (guide 5.2).
  final List<String> allergens;

  /// Fibre per 100 g (guide 5.2). Null when the server sends none.
  final double? fiberGPer100g;

<<<<<<< HEAD
  /// The aisle the shopping list puts it in (guide 5.4), such as `produce`.
  /// Null when the server sends none.
  final String? shoppingSection;

=======
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
  const SearchableFood(
      {required this.name,
      required this.caloriesPer100g,
      required this.macro,
      this.category = 'default',
      this.id,
      this.allergens = const [],
<<<<<<< HEAD
      this.fiberGPer100g,
      this.shoppingSection});
=======
      this.fiberGPer100g});
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
}
