<<<<<<< HEAD
import '../../core/errors/failure.dart';
=======
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
import '../../core/errors/result.dart';
import '../entities/meal_entities.dart';
import '../entities/meal_plan_entities.dart';

/// The patient's meal log (planned meals marked as eaten + off-plan foods).
///
/// Implementations persist locally so logs survive a restart. Off-plan foods
/// are also sent to the server through the offline queue (API guide 6.1, 14).
abstract interface class MealLogRepository {
  Future<Result<List<MealLogEntry>>> getEntries();

  /// Marks a planned meal as logged. Logging the same meal again on the same
  /// day returns the existing entry instead of duplicating it.
  ///
  /// For a meal from the server's plan ([Meal.source]) each food eaten is also
  /// sent to the server with its `meal_item_id` (API guide 6.1), so the
  /// nutritionist sees it. [eaten] is what the patient chose per planned item
  /// (the item or one of its alternatives); by default the planned items.
  Future<Result<MealLogEntry>> logPlanned(Meal meal, {List<PlanItem>? eaten});

  /// Records an off-plan food with the chosen portion (grams).
  Future<Result<MealLogEntry>> logFood(SearchableFood food,
      {required int grams});

<<<<<<< HEAD
  /// Deletes the entry here and its logs on the server (API guide 6.4). Logs
  /// still waiting in the offline queue are taken out unsent. Needs a
  /// connection for the logs the server already has (14): offline, it fails
  /// with a [NetworkFailure] and the entry stays. `403 log_locked` means the
  /// edit window has passed. A log the server no longer has (404) counts as
  /// deleted.
  Future<Result<void>> delete(String entryId);

  /// Reads [day]'s logs from the server (API guide 6.2), so logs made on
  /// another device, or before a reinstall, show here, and logs deleted
  /// elsewhere go. [planMeals] are [day]'s plan meals: a planned log joins
  /// its meal. Offline, it fails and the entries stay as they are.
  Future<Result<void>> syncDay(DateTime day, {List<Meal> planMeals});

  /// Changes the grams of a one-food entry here and on the server (6.3).
  /// Only for an entry whose [MealLogEntry.canEditGramsAt] is true. Needs a
  /// connection. `403 log_locked`: the edit window has passed. A log the
  /// server no longer has (404) is removed here as well.
  Future<Result<MealLogEntry>> updateGrams(String entryId, int grams);

=======
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
  Future<Result<void>> clear();
}
