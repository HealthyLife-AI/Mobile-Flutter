import '../../core/config/app_config.dart';
import '../mock/meal_mock_data.dart';
import '../models/meal_dto.dart';

/// Remote contract for the meal plan. The mock implementation ships the
/// same DTO shapes a real backend would return; replacing it with an HTTP
/// implementation (backed by `ApiClient`) requires no repository changes.
abstract interface class MealPlanRemoteDataSource {
  Future<List<MealDto>> fetchTodayPlan();

  /// Smart-swap groups for one meal. The mock feed only contains lunch
  /// groups (mirroring the current content set).
  Future<List<FoodCategoryGroupDto>> fetchSwapOptions(String mealId);
}

class MockMealPlanRemoteDataSource implements MealPlanRemoteDataSource {
  const MockMealPlanRemoteDataSource({this.latency = AppConfig.mockLatency});

  final Duration latency;

  @override
  Future<List<MealDto>> fetchTodayPlan() async {
    await Future<void>.delayed(latency);
    return MockData.todayMeals.map(MealDto.fromEntity).toList();
  }

  @override
  Future<List<FoodCategoryGroupDto>> fetchSwapOptions(String mealId) async {
    await Future<void>.delayed(latency);
    return MockData.lunchDetailGroups.map(FoodCategoryGroupDto.fromEntity).toList();
  }
}
