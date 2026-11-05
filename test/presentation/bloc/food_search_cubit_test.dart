import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/core/errors/result.dart';
import 'package:healthylife_ai/domain/entities/meal_entities.dart';
import 'package:healthylife_ai/domain/entities/patient_health_profile_entities.dart';
import 'package:healthylife_ai/domain/entities/recommendation_entity.dart';
import 'package:healthylife_ai/domain/repositories/food_repository.dart';
import 'package:healthylife_ai/domain/repositories/health_profile_repository.dart';
import 'package:healthylife_ai/domain/usecases/search_foods_use_case.dart';
import 'package:healthylife_ai/presentation/bloc/food_search/food_search_cubit.dart';

/// Answers each search with the next scripted result. When none is left, it
/// answers with no foods.
class _ScriptedFoods implements FoodRepository {
  final List<Result<List<SearchableFood>>> results = [];
  final List<String> searches = [];

  @override
  Future<Result<List<SearchableFood>>> search(String query) async {
    searches.add(query);
    return results.isEmpty
        ? const Success(<SearchableFood>[])
        : results.removeAt(0);
  }

  @override
  Future<Result<List<RecommendationItem>>> getRecommendedRecipes() =>
      throw UnimplementedError();
}

/// Answers the health profile with one scripted result.
class _ScriptedProfile implements HealthProfileRepository {
  _ScriptedProfile(this.answer);

  final Result<PatientHealthProfile> answer;

  @override
  Future<Result<PatientHealthProfile>> getProfile() async => answer;

  @override
  Future<Result<void>> propose(ChangeRequestDraft draft) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> withdraw(int proposalId) => throw UnimplementedError();
}

const SearchableFood _apples = SearchableFood(
  id: 1,
  name: 'تفاح',
  caloriesPer100g: 52,
  macro: 'carbs',
  category: 'greenFruit',
);

/// Long enough for the zero-delay debounce timer and the search to finish.
const Duration _settle = Duration(milliseconds: 20);

FoodSearchCubit _cubit(_ScriptedFoods foods,
        {HealthProfileRepository? healthProfile}) =>
    FoodSearchCubit(
      SearchFoodsUseCase(foods),
      debounce: Duration.zero,
      healthProfile: healthProfile,
    );

void main() {
  test('the allergy groups are the approved ones, without other', () async {
    final profile = _ScriptedProfile(Success(PatientHealthProfile(
      allergies: const [
        AllergyItem(
          label: 'المكسرات',
          group: 'tree_nuts',
          allergyClass: 'confirmed_allergy',
        ),
        AllergyItem(
          label: 'نص حر',
          group: 'other',
          otherText: 'نص حر',
          allergyClass: 'avoid',
        ),
        AllergyItem(label: 'بيض', allergyClass: 'intolerance'),
      ],
    )));
    final cubit = _cubit(_ScriptedFoods(), healthProfile: profile);
    addTearDown(cubit.close);

    await cubit.loadAllergies();

    expect(cubit.state.allergyGroups, {'tree_nuts'});
    expect(cubit.state.allergyCheckFailed, isFalse);
  });

  test('a profile that cannot be read leaves the badge off, and search works',
      () async {
    final foods = _ScriptedFoods()..results.add(Success([_apples]));
    final cubit = _cubit(
      foods,
      healthProfile: _ScriptedProfile(
        Failed<PatientHealthProfile>(const NetworkFailure()),
      ),
    );
    addTearDown(cubit.close);

    await cubit.loadAllergies();
    cubit.queryChanged('ta');
    await Future<void>.delayed(_settle);

    expect(cubit.state.allergyGroups, isEmpty);
    expect(cubit.state.allergyCheckFailed, isTrue);
    expect(cubit.state.status, FoodSearchStatus.results);
    expect(cubit.state.results, [_apples]);
  });

  test(
      'a search runs once two letters are typed, and a shorter one is not sent',
      () async {
    final foods = _ScriptedFoods()..results.add(Success([_apples]));
    final cubit = _cubit(foods);
    addTearDown(cubit.close);

    cubit.queryChanged('t');
    await Future<void>.delayed(_settle);
    expect(foods.searches, isEmpty);

    cubit.queryChanged('ta');
    await Future<void>.delayed(_settle);

    expect(foods.searches, ['ta']);
    expect(cubit.state.status, FoodSearchStatus.results);
  });

  test('a failed search keeps the failure, for the error view to show',
      () async {
    final foods = _ScriptedFoods()
      ..results.add(Failed<List<SearchableFood>>(const NetworkFailure()));
    final cubit = _cubit(foods);
    addTearDown(cubit.close);

    cubit.queryChanged('ta');
    await Future<void>.delayed(_settle);

    expect(cubit.state.status, FoodSearchStatus.error);
    expect(cubit.state.failure, isA<NetworkFailure>());
  });
}
