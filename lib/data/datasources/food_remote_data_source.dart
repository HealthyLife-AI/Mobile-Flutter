import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/food_dto.dart';

/// `GET /foods/search?q=&per_page=` (API guide 5.5). Reads the first page only,
/// at the largest size the server gives (50). The search screen shows that page.
class FoodRemoteDataSource {
  FoodRemoteDataSource(this._api);

  static const int pageSize = 50;

  final ApiClient _api;

  Future<List<FoodDto>> search(String query) async {
    final raw = await _api.get(
      'foods/search',
      query: {'q': query, 'per_page': pageSize},
    );
    final data = raw is Map ? raw['data'] : null;
    if (data is! List) {
      throw const ParseException(
          'The food search answer has an unexpected shape');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(FoodDto.fromJson)
        .whereType<FoodDto>()
        .toList();
  }
}
