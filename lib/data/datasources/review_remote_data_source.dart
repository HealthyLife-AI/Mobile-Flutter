import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';

/// The notes endpoints (API guide 9.2). The writes answer with nothing the
/// app needs, so they return nothing. The cubit reads the list again after a
/// write succeeds.
class ReviewRemoteDataSource {
  ReviewRemoteDataSource(this._api);

  final ApiClient _api;

  /// `GET /me/reviews`: a plain array, newest first.
  Future<List<Map<String, dynamic>>> fetchReviews() async {
    final raw = await _api.get('me/reviews');
    if (raw is! List) {
      throw const ParseException('The notes answer is not a list');
    }
    return [
      for (final item in raw)
        if (item is Map) Map<String, dynamic>.from(item),
    ];
  }

  /// `POST /me/reviews/{id}/acknowledge`. Safe to repeat.
  Future<void> acknowledge(int reviewId) async {
    await _api.post('me/reviews/$reviewId/acknowledge');
  }

  /// `POST` marks a task done, and `DELETE` marks it not done. Both are safe
  /// to repeat, and both give 404 for another patient's task.
  Future<void> setTaskDone(int taskId, {required bool done}) async {
    if (done) {
      await _api.post('me/tasks/$taskId/done');
    } else {
      await _api.delete('me/tasks/$taskId/done');
    }
  }
}
