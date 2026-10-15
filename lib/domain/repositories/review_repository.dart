import '../../core/errors/result.dart';
import '../entities/review_entities.dart';

/// The nutritionist's notes (API guide 9.2). Reads keep the last answer for
/// offline use. Writes are sent once and never queued: they need a connection.
abstract interface class ReviewRepository {
  /// Newest first, as the server sends them.
  Future<Result<List<NutritionistReview>>> getReviews();

  /// The «فهمت» button (`POST me/reviews/{id}/acknowledge`).
  Future<Result<void>> acknowledge(int reviewId);

  /// Ticks or unticks a task (`POST` or `DELETE me/tasks/{id}/done`).
  Future<Result<void>> setTaskDone(int taskId, {required bool done});
}
