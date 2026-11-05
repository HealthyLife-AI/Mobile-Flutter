import '../../core/errors/result.dart';
import '../entities/engagement_entities.dart';
import '../entities/health_records_entities.dart';

/// `GET /me/checkins/current`, `POST /me/checkins/{id}`.
abstract interface class CheckinRepository {
  /// The check-in waiting for answers, or null when there is none.
  Future<Result<Checkin?>> getCurrent();

  /// A 409 comes back as an `ApiFailure` with code `checkin_expired` or
  /// `checkin_already_submitted`; a 422 with `answers.<key>` field errors.
  Future<Result<void>> submit(int checkinId, CheckinAnswers answers);

  Future<CheckinDraft?> readDraft(int checkinId);
  Future<void> saveDraft(CheckinDraft draft);
  Future<void> clearDraft();
}

/// `GET` / `PUT /me/food-preferences`.
abstract interface class FoodPreferencesRepository {
  Future<Result<FoodPreferences>> get();

  /// Replaces the patient's own entries; the nutritionist's stay.
  Future<Result<FoodPreferences>> save(
      {required List<int> likes, required List<int> dislikes});
}

/// `GET /me/goal-projection` and `GET /me/weight-insight`; both null until
/// the nutritionist enables them.
abstract interface class InsightsRepository {
  Future<Result<GoalProjection?>> getGoalProjection();
  Future<Result<WeightInsight?>> getWeightInsight();
}

/// `GET /me/today`.
abstract interface class TodayRepository {
  Future<Result<TodaySummary>> getToday();
}

/// `/me/posts`: the nutritionist's advice.
abstract interface class PostsRepository {
  Future<Result<PostsPage>> getPage(int page);

  /// A 404 (withdrawn, or no longer for this patient) is a `NotFoundFailure`.
  Future<Result<Post>> getPost(int id);

  /// Safe to repeat.
  Future<Result<void>> markRead(int id);
  Future<Result<int>> unreadCount();
}

/// Consent and `/me/reports`. A 404 from any of them means the feature is
/// off: the methods answer null and the section is hidden.
abstract interface class MedicalReportsRepository {
  Future<Result<ReportsConsent?>> getConsent();
  Future<Result<void>> acceptConsent();

  Future<Result<List<MedicalReport>?>> getReports();

  /// The file, held in memory only (never saved to the gallery or a cache).
  Future<Result<List<int>>> downloadFile(int id);
  Future<Result<void>> delete(int id);

  /// [onProgress] gets 0..1. A failure with its own message (too large, wrong
  /// type, consent needed…) carries the server's code; the data layer's
  /// `reportUploadErrorOf` reads it.
  Future<Result<MedicalReport>> upload(ReportUpload upload,
      {void Function(double progress)? onProgress});
}

/// `/me/wellbeing`.
abstract interface class WellbeingRepository {
  /// Oldest first.
  Future<Result<List<WellbeingEntry>>> getRange(DateTime from, DateTime to);

  /// Replaces the whole day: a field left null is cleared on the server.
  Future<Result<WellbeingEntry>> save(WellbeingEntry entry);
  Future<Result<void>> delete(DateTime date);
}
