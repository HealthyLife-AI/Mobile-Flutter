import '../../core/errors/result.dart';
import '../entities/patient_care_entities.dart';

/// `GET /me/measurement-schedule`.
abstract interface class MeasurementScheduleRepository {
  /// The schedule, or null when the nutritionist has not set one.
  Future<Result<MeasurementSchedule?>> getSchedule();
}

/// `GET` and `POST /me/quick-requests`.
abstract interface class QuickRequestRepository {
  /// Newest first. Reading the list marks the replies read on the server.
  Future<Result<List<QuickRequest>>> getRequests();

  /// A 422 comes back as an `ApiFailure` with field errors, and the daily
  /// limit as an `ApiFailure` with code `quick_request_limit` (429).
  Future<Result<QuickRequest>> send(QuickRequestDraft draft);
}
