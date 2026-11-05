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
      patientInstructions:
          parsePatientInstructions(json['patient_instructions']),
      activities: _activities(json['activities']),
    );
  }

  /// `activities[]`, in `sort_order`. An entry without an id, a title or a
  /// positive duration cannot be shown and is skipped.
  static List<PlanActivity> _activities(Object? raw) {
    if (raw is! List) return const [];
    final activities = <PlanActivity>[];
    for (final entry in raw.whereType<Map>()) {
      final json = Map<String, dynamic>.from(entry);
      final id = _int(json['id']);
      final title = _text(json['title']);
      final minutes = _int(json['duration_minutes']);
      if (id == null || title == null || minutes == null || minutes <= 0) {
        continue;
      }
      final days = _int(json['days_per_week']);
      activities.add(PlanActivity(
        id: id,
        title: title,
        description: _text(json['description']),
        durationMinutes: minutes,
        timesPerDay: (_int(json['times_per_day']) ?? 1).clamp(1, 99),
        daysPerWeek: days != null && days >= 1 && days <= 7 ? days : null,
        sortOrder: _int(json['sort_order']) ?? 0,
      ));
    }
    // A stable sort, so equal sort orders keep the server's order.
    final indexed = activities.indexed.toList()
      ..sort((a, b) {
        final byOrder = a.$2.sortOrder.compareTo(b.$2.sortOrder);
        return byOrder != 0 ? byOrder : a.$1.compareTo(b.$1);
      });
    return [for (final (_, activity) in indexed) activity];
  }

  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
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
        // On the item (5.1); the food object is the fallback.
        costTier: _costTier(json['cost_tier'] ??
            (foodJson is Map ? foodJson['cost_tier'] : null)),
        prepLevel: _prepLevel(json['prep_level'] ??
            (foodJson is Map ? foodJson['prep_level'] : null)),
      ));
    }
    return items;
  }

  static FoodCostTier _costTier(Object? raw) => switch (raw) {
        'economical' => FoodCostTier.economical,
        'standard' => FoodCostTier.standard,
        'premium' => FoodCostTier.premium,
        _ => FoodCostTier.unknown,
      };

  static FoodPrepLevel _prepLevel(Object? raw) => switch (raw) {
        'no_cook' => FoodPrepLevel.noCook,
        'easy' => FoodPrepLevel.easy,
        'normal' => FoodPrepLevel.normal,
        _ => FoodPrepLevel.unknown,
      };

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

// A "- " or "• " the nutritionist typed would otherwise render as a second
// bullet next to the card's own dot.
final RegExp _listMarker = RegExp(r'^[•·\-–*]\s+');

// Zero-width and bidi control characters (U+200B-U+200F, U+202A-U+202E,
// U+2060-U+206F): a line made only of these and spaces looks empty on
// screen, so it is treated as empty.
bool _isInvisible(int rune) =>
    (rune >= 0x200B && rune <= 0x200F) ||
    (rune >= 0x202A && rune <= 0x202E) ||
    (rune >= 0x2060 && rune <= 0x206F);

bool _looksEmpty(String line) =>
    String.fromCharCodes(line.runes.where((r) => !_isInvisible(r)))
        .trim()
        .isEmpty;

/// Splits `patient_instructions` (plain text, lines separated by `\n`, up to
/// 2000 characters) into bullet lines. `null`, a non-string, an empty string
/// and whitespace-only text all give `[]`.
List<String> parsePatientInstructions(Object? raw) {
  if (raw is! String) return const [];
  return raw
      .split(RegExp(r'\r\n|\r|\n'))
      .map((line) => line.trim().replaceFirst(_listMarker, ''))
      .where((line) => !_looksEmpty(line))
      .toList(growable: false);
}
