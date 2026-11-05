import '../../core/errors/result.dart';
import '../entities/meal_entities.dart';
import '../entities/meal_plan_entities.dart';

/// The patient's meal log (planned meals marked as eaten + off-plan foods).
///
/// Implementations persist locally so logs survive a restart. Off-plan foods
/// are also sent to the server through the offline queue (API guide 6.1, 14).
abstract interface class MealLogRepository {
  Future<Result<List<MealLogEntry>>> getEntries();

  /// Marks a planned meal as logged. Logging the same meal again on the same
  /// day returns the existing entry instead of duplicating it.
  ///
  /// For a meal from the server's plan ([Meal.source]) each food eaten is also
  /// sent to the server with its `meal_item_id` (API guide 6.1), so the
  /// nutritionist sees it. [eaten] is what the patient chose per planned item
  /// (the item or one of its alternatives); by default the planned items.
  Future<Result<MealLogEntry>> logPlanned(Meal meal, {List<PlanItem>? eaten});

  /// Records an off-plan food with the chosen portion (grams).
  Future<Result<MealLogEntry>> logFood(SearchableFood food,
      {required int grams});

  Future<Result<void>> clear();
}
