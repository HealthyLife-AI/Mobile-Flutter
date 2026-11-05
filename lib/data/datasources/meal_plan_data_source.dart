import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';

/// `GET /me/meal-plan` (API guide 5.1).
abstract interface class MealPlanRemoteDataSource {
  /// The active plan as the server sent it, or null when there is none yet
  /// (`204 No Content`).
  Future<Map<String, dynamic>?> fetchActivePlan();
}

class HttpMealPlanRemoteDataSource implements MealPlanRemoteDataSource {
  HttpMealPlanRemoteDataSource(this._api);

  final ApiClient _api;

  @override
  Future<Map<String, dynamic>?> fetchActivePlan() async {
    final raw = await _api.get('me/meal-plan');
    // 204 arrives as null or an empty body: no active plan yet.
    if (raw == null || raw == '') return null;
    if (raw is! Map) {
      throw const ParseException('The meal plan is not an object');
    }
    return Map<String, dynamic>.from(raw);
  }
}
