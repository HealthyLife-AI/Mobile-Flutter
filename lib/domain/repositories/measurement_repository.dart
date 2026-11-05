import '../../core/errors/result.dart';
import '../entities/measurement_entities.dart';

/// Body measurements: the readings from the server, plus any still waiting in
/// the offline queue.
abstract interface class MeasurementRepository {
  Future<Result<MeasurementSnapshot>> getSnapshot();

  /// Validates + persists a new reading (weights/circumferences already
  /// validated by the use case; range enforcement also happens there).
  Future<Result<MeasurementSnapshot>> saveEntry(MeasurementEntry entry);

  /// Deletes one of the patient's own readings (API guide 7.3) and returns the
  /// readings left. A reading still waiting in the offline queue is taken out
  /// unsent. The server refuses a clinic reading (`403
  /// reading_not_deletable`) and one past its window (`403 log_locked`); a
  /// reading it no longer has (404) counts as deleted.
  Future<Result<MeasurementSnapshot>> deleteEntry(MeasurementEntry entry);
}
