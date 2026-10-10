import '../../core/errors/result.dart';
import '../entities/meal_entities.dart';
import '../entities/recommendation_entity.dart';

/// Food database search + recommendation content.
abstract interface class FoodRepository {
  /// Empty/blank [query] returns the suggested (popular) foods.
  Future<Result<List<SearchableFood>>> search(String query);

  /// Recommended recipe cards for the home/dashboard carousels.
  Future<Result<List<RecommendationItem>>> getRecommendedRecipes();
}
