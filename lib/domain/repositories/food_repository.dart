import '../../core/errors/result.dart';
import '../entities/meal_entities.dart';

/// Food database search.
abstract interface class FoodRepository {
  /// Searches approved foods. The server takes queries of two characters or
  /// more (guide 5.5). SearchFoodsUseCase keeps shorter ones from reaching it.
  Future<Result<List<SearchableFood>>> search(String query);
}
