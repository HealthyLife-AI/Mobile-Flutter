import '../../core/errors/result.dart';
import '../entities/measurement_entities.dart';

/// Body measurements: baseline (clinic/mock) data merged with locally
/// saved readings.
abstract interface class MeasurementRepository {
  Future<Result<MeasurementSnapshot>> getSnapshot();

  /// Validates + persists a new reading (weights/circumferences already
  /// validated by the use case; range enforcement also happens there).
  Future<Result<MeasurementSnapshot>> saveEntry(MeasurementEntry entry);
}
