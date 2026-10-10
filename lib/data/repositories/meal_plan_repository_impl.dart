import '../../core/errors/exception_mapper.dart';
import '../../core/errors/result.dart';
import '../../domain/entities/meal_entities.dart';
import '../../domain/repositories/meal_plan_repository.dart';
import '../datasources/meal_plan_data_source.dart';

class MealPlanRepositoryImpl implements MealPlanRepository {
  MealPlanRepositoryImpl(this._remote);

  final MealPlanRemoteDataSource _remote;

  @override
  Future<Result<List<Meal>>> getTodayMeals() => guard(
        () async => (await _remote.fetchTodayPlan()).map((dto) => dto.toEntity()).toList(),
        context: 'MealPlanRepository.getTodayMeals',
      );

  @override
  Future<Result<List<FoodCategoryGroup>>> getSwapOptions(String mealId) => guard(
        () async => (await _remote.fetchSwapOptions(mealId)).map((dto) => dto.toEntity()).toList(),
        context: 'MealPlanRepository.getSwapOptions',
      );
}
