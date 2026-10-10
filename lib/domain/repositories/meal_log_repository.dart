import '../../core/errors/result.dart';
import '../entities/meal_entities.dart';

/// The patient's meal log (planned meals marked as eaten + off-plan foods).
///
/// Implementations persist locally so logs survive a restart; a future
/// remote implementation will sync with the backend (idempotency keys per
/// the API reference).
abstract interface class MealLogRepository {
  Future<Result<List<MealLogEntry>>> getEntries();

  /// Marks a planned meal as logged. Logging the same meal twice returns
  /// the existing entry instead of duplicating it.
  Future<Result<MealLogEntry>> logPlanned(Meal meal);

  /// Records an off-plan food with the chosen portion (grams).
  Future<Result<MealLogEntry>> logFood(SearchableFood food, {required int grams});

  Future<Result<void>> clear();
}
