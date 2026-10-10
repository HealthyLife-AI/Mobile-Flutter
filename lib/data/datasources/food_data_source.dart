import '../../core/config/app_config.dart';
import '../mock/meal_mock_data.dart';
import '../models/meal_dto.dart';

/// Food search + recommendations feed (mock now, HTTP later).
abstract interface class FoodDataSource {
  Future<List<SearchableFoodDto>> search(String query);
}

class MockFoodDataSource implements FoodDataSource {
  const MockFoodDataSource({this.latency = AppConfig.mockLatency});

  final Duration latency;

  @override
  Future<List<SearchableFoodDto>> search(String query) async {
    await Future<void>.delayed(latency);
    final q = query.trim();
    if (q.isEmpty) {
      return MockData.foodSearchResults.map(SearchableFoodDto.fromEntity).toList();
    }
    // Simple substring match over the mock catalog — a real backend would
    // do this server-side with the same response shape.
    return MockData.foodSearchResults
        .where((f) => f.name.contains(q))
        .map(SearchableFoodDto.fromEntity)
        .toList();
  }
}
