import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/result.dart';
import 'package:healthylife_ai/domain/entities/meal_entities.dart';
import 'package:healthylife_ai/domain/entities/recommendation_entity.dart';
import 'package:healthylife_ai/domain/repositories/food_repository.dart';
import 'package:healthylife_ai/domain/usecases/search_foods_use_case.dart';

/// Records each search the use case passes on.
class _RecordingFoods implements FoodRepository {
  final List<String> searches = [];

  @override
  Future<Result<List<SearchableFood>>> search(String query) async {
    searches.add(query);
    return const Success(<SearchableFood>[]);
  }

  @override
  Future<Result<List<RecommendationItem>>> getRecommendedRecipes() =>
      throw UnimplementedError();
}

void main() {
  late _RecordingFoods foods;
  late SearchFoodsUseCase search;

  setUp(() {
    foods = _RecordingFoods();
    search = SearchFoodsUseCase(foods);
  });

  test('a blank or one-letter query makes no call', () async {
    await search('');
    await search('   ');
    await search(' a ');

    expect(foods.searches, isEmpty);
  });

  test('a query of two characters or more is sent, trimmed', () async {
    await search('  tuna  ');
    await search('ta');

    expect(foods.searches, ['tuna', 'ta']);
  });

  test('a short query answers with no foods', () async {
    final result = await search('a');

    expect(result.valueOrNull, isEmpty);
  });
}
