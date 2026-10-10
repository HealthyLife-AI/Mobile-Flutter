import '../../core/errors/result.dart';
import '../entities/meal_entities.dart';

/// Today's generated meal plan.
abstract interface class MealPlanRepository {
  Future<Result<List<Meal>>> getTodayMeals();

  /// Smart-swap options for one meal (protein / carbs / vegetables groups).
  Future<Result<List<FoodCategoryGroup>>> getSwapOptions(String mealId);
}
