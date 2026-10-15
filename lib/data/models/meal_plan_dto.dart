import '../../domain/entities/meal_plan_entities.dart';
import 'food_dto.dart';

/// Reads `GET /me/meal-plan` (API guide 5.1) into a [MealPlan].
///
/// Lenient on purpose: an item without a usable food (5.2) is skipped, since it
/// can be neither shown nor logged, and a meal left with no items is dropped.
/// A plan without an id is unreadable.
abstract final class MealPlanDto {
  static MealPlan? fromJson(Map<String, dynamic> json) {
    final id = _int(json['id']);
    if (id == null) return null;
    final meals = <PlanMeal>[];
    final rawMeals = json['meals'];
    if (rawMeals is List) {
      for (final raw in rawMeals.whereType<Map>()) {
        final meal = _meal(Map<String, dynamic>.from(raw));
        if (meal != null) meals.add(meal);
      }
    }
    return MealPlan(
      id: id,
      startDate: _date(json['start_date']),
      meals: meals,
      summaryByDay: _summary(json['summary_by_day']),
    );
  }

  static PlanMeal? _meal(Map<String, dynamic> json) {
    final id = _int(json['id']);
    if (id == null) return null;
    final items = _items(json['items']);
    if (items.isEmpty) return null;
    final day = _int(json['day_index']);
    return PlanMeal(
      id: id,
      type: _type(json['name']),
      dayIndex: day != null && day >= 0 && day <= 6 ? day : null,
      macros: _macros(json['macros']),
      items: items,
    );
  }

  static List<PlanItem> _items(Object? raw) {
    if (raw is! List) return const [];
    final items = <PlanItem>[];
    for (final entry in raw.whereType<Map>()) {
      final json = Map<String, dynamic>.from(entry);
      final id = _int(json['id']);
      final foodJson = json['food'];
      final food =
          foodJson is Map ? FoodDto.fromJson(Map.from(foodJson)) : null;
      if (id == null || food == null) continue;
      items.add(PlanItem(
        id: id,
        food: food.toEntity(),
        quantityGrams: _int(json['quantity_grams']) ??
            (json['quantity_grams'] is num
                ? (json['quantity_grams'] as num).round()
                : 0),
        macros: _macros(json['macros']),
        alternatives: _items(json['alternatives']),
      ));
    }
    return items;
  }

  static PlanMealType _type(Object? name) => switch (name) {
        'breakfast' => PlanMealType.breakfast,
        'snack' => PlanMealType.snack,
        'lunch' => PlanMealType.lunch,
        'dinner' => PlanMealType.dinner,
        _ => PlanMealType.other,
      };

  static Map<int, Macros> _summary(Object? raw) {
    if (raw is! Map) return const {};
    final summary = <int, Macros>{};
    raw.forEach((key, value) {
      final day = int.tryParse('$key');
      if (day != null && day >= 0 && day <= 6 && value is Map) {
        summary[day] = _macros(value);
      }
    });
    return summary;
  }

  static Macros _macros(Object? raw) {
    if (raw is! Map) return Macros.zero;
    double n(Object? v) => v is num ? v.toDouble() : 0;
    return Macros(
      calories: n(raw['calories']),
      proteinG: n(raw['protein_g']),
      carbsG: n(raw['carbs_g']),
      fatG: n(raw['fat_g']),
    );
  }

  static int? _int(Object? value) {
    if (value is int) return value;
    if (value is num && value == value.roundToDouble()) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;
}
