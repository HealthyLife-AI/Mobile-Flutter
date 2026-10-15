import '../../core/errors/failure.dart';
import '../../core/errors/result.dart';
import '../entities/meal_entities.dart';
import '../entities/meal_plan_entities.dart';
import '../repositories/meal_log_repository.dart';

/// Logs a meal — planned or off-plan — with validation and a short-window
/// duplicate guard so a double tap can never create two entries.
class LogMealUseCase {
  LogMealUseCase(this._repository,
      {this.duplicateWindow = const Duration(seconds: 2)});

  final MealLogRepository _repository;
  final Duration duplicateWindow;
  DateTime? _lastLoggedAt;
  String? _lastLoggedKey;

  Future<Result<MealLogEntry>> logPlanned(Meal meal,
      {List<PlanItem>? eaten}) async {
    final key = 'planned-${meal.id}';
    if (_isDuplicate(key)) {
      final entries = await _repository.getEntries();
      final existing = entries.valueOrNull
          ?.where((e) => e.plannedMeal?.id == meal.id)
          .firstOrNull;
      if (existing != null) return Success(existing);
      if (entries is Failed<List<MealLogEntry>>) return Failed(entries.failure);
    }
    final result = await _repository.logPlanned(meal, eaten: eaten);
    if (result.isSuccess) _markLogged(key);
    return result;
  }

  Future<Result<MealLogEntry>> logFood(SearchableFood food,
      {required int grams}) async {
    if (grams < 1 || grams > 2000) {
      return const Failed(
          ValidationFailure(fieldErrors: {'grams': 'validation.outOfRange'}));
    }
    final key = 'food-${food.name}';
    if (_isDuplicate(key)) {
      final entries = await _repository.getEntries();
      final last = entries.valueOrNull?.isNotEmpty == true
          ? entries.valueOrNull!.last
          : null;
      if (last != null && last.isOffPlan && last.name == food.name) {
        return Success(last);
      }
    }
    final result = await _repository.logFood(food, grams: grams);
    if (result.isSuccess) _markLogged(key);
    return result;
  }

  bool _isDuplicate(String key) {
    final last = _lastLoggedAt;
    return last != null &&
        _lastLoggedKey == key &&
        DateTime.now().difference(last) <= duplicateWindow;
  }

  void _markLogged(String key) {
    _lastLoggedAt = DateTime.now();
    _lastLoggedKey = key;
  }
}
