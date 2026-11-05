import '../../core/errors/result.dart';
import '../entities/meal_entities.dart';
import '../repositories/food_repository.dart';

/// Food search with input normalization. The server searches only from two
/// characters (guide 5.5), and it has no list of suggested foods. So a shorter
/// query gives no results and makes no call.
class SearchFoodsUseCase {
  SearchFoodsUseCase(this._repository);

  final FoodRepository _repository;

  Future<Result<List<SearchableFood>>> call(String rawQuery) {
    final query = rawQuery.trim();
    if (query.length < 2) {
      return Future.value(const Success(<SearchableFood>[]));
    }
    return _repository.search(query);
  }
}
