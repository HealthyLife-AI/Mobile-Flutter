import '../../core/errors/result.dart';
import '../entities/meal_entities.dart';
import '../entities/recommendation_entity.dart';

/// Food database search + recommendation content.
abstract interface class FoodRepository {
  /// Searches approved foods. The server takes queries of two characters or
  /// more (guide 5.5). SearchFoodsUseCase keeps shorter ones from reaching it.
  Future<Result<List<SearchableFood>>> search(String query);

  /// Recommended recipe cards for the home/dashboard carousels.
  Future<Result<List<RecommendationItem>>> getRecommendedRecipes();
}
