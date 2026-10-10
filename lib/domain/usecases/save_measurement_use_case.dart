import '../../core/errors/failure.dart';
import '../../core/errors/result.dart';
import '../entities/measurement_entities.dart';
import '../repositories/measurement_repository.dart';

/// Validates a measurement reading (ranges, at least one value) and saves
/// it. Validation lives here — not in the widget — so it is enforced no
/// matter which screen submits.
class SaveMeasurementUseCase {
  SaveMeasurementUseCase(this._repository);

  final MeasurementRepository _repository;

  Future<Result<MeasurementSnapshot>> call(MeasurementEntry entry) async {
    final hasAnyValue = entry.weightKg != null ||
        entry.waistCm != null ||
        entry.hipCm != null ||
        entry.thighCm != null ||
        entry.armCm != null;
    if (!hasAnyValue) {
      return const Failed(ValidationFailure(fieldErrors: {'entry': 'validation.required'}));
    }
    if (entry.weightKg != null && (entry.weightKg! < 20 || entry.weightKg! > 300)) {
      return const Failed(ValidationFailure(fieldErrors: {'weight': 'validation.outOfRange'}));
    }
    for (final cm in [entry.waistCm, entry.hipCm, entry.thighCm, entry.armCm]) {
      if (cm != null && (cm < 20 || cm > 250)) {
        return const Failed(ValidationFailure(fieldErrors: {'circumference': 'validation.outOfRange'}));
      }
    }
    return _repository.saveEntry(entry);
  }
}
