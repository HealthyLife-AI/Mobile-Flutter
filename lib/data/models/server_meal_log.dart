import 'food_dto.dart';
import 'json_read.dart';

/// One log object as `GET /me/meal-logs` and `PATCH /me/meal-logs/{id}`
/// answer (API guide 6.1).
class ServerMealLog {
  const ServerMealLog({
    required this.id,
    required this.foodName,
    required this.grams,
    required this.calories,
    required this.loggedAt,
    required this.logKind,
    this.mealItemId,
    this.editableUntil,
  });

  final int id;

  /// `name_ar`, or `name_en` when there is no Arabic (5.2).
  final String foodName;
  final int grams;
  final double calories;

  /// When it was eaten, in the device's own time.
  final DateTime loggedAt;

  /// `planned`, `alternative` or `off_plan`. Fixed when logged.
  final String logKind;

  /// The plan item or alternative eaten. Null for food outside the plan, and
  /// once the nutritionist removed that item from the plan.
  final int? mealItemId;

  /// Until then the log can be edited or deleted.
  final DateTime? editableUntil;

  bool get isOffPlan => logKind == 'off_plan';

  /// Null when the object lacks what the screens need: an id, a food, the
  /// grams or the time.
  static ServerMealLog? fromJson(Map<String, dynamic> json) {
    final id = jsonInt(json['id']);
    final grams = jsonInt(json['quantity_grams']);
    final loggedAt = jsonDateTime(json['logged_at']);
    final food = jsonMap(json['food']);
    final name = food == null ? null : FoodDto.fromJson(food)?.name;
    if (id == null || grams == null || loggedAt == null || name == null) {
      return null;
    }
    return ServerMealLog(
      id: id,
      foodName: name,
      grams: grams,
      calories: jsonDouble(jsonMap(json['macros'])?['calories']) ?? 0,
      loggedAt: loggedAt,
      logKind: jsonText(json['log_kind']) ?? 'off_plan',
      mealItemId: jsonInt(json['meal_item_id']),
      editableUntil: jsonDateTime(json['editable_until']),
    );
  }
}
