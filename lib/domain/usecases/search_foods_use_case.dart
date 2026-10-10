import '../../core/errors/result.dart';
import '../entities/meal_entities.dart';
import '../repositories/food_repository.dart';

/// Food search with input normalization. Empty queries return the
/// suggested list (what the food-search screen shows before typing).
class SearchFoodsUseCase {
  SearchFoodsUseCase(this._repository);

  final FoodRepository _repository;

  Future<Result<List<SearchableFood>>> call(String rawQuery) {
    final query = rawQuery.trim();
    if (query.isEmpty) return _repository.search('');
    if (query.length < 2) return Future.value(const Success(<SearchableFood>[]));
    return _repository.search(query);
  }
}
