import '../../core/errors/result.dart';
import '../entities/meal_plan_entities.dart';

/// The patient's active meal plan, as the nutritionist set it (API guide 5.1).
abstract interface class MealPlanRepository {
  /// The active plan, or null when the nutritionist has not activated one
  /// yet (`204`), which screens show as an empty state, not an error.
  Future<Result<MealPlan?>> getActivePlan();
}
