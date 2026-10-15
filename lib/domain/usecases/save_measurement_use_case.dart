import '../../core/errors/failure.dart';
import '../../core/errors/result.dart';
import '../entities/measurement_entities.dart';
import '../repositories/measurement_repository.dart';

/// Validates a measurement reading and saves it. Validation lives here, not in
/// the widget, so it is enforced no matter which screen submits (API guide
/// 7.1).
class SaveMeasurementUseCase {
  SaveMeasurementUseCase(this._repository);

  /// Accepted weight in kg, both ends included (7.1).
  static const (int, int) weightRangeKg = (20, 300);

  /// Accepted circumferences in cm, by field name (7.1). The screens show these
  /// same limits, so they are defined once, here.
  static const Map<String, (int, int)> circumferenceRangeCm = {
    'waist': (20, 300),
    'hip': (20, 300),
    'thigh': (10, 200),
    'arm': (10, 150),
  };

  final MeasurementRepository _repository;

  /// Refusals are keyed by field: `weight`, `waist`, `hip`, `thigh` or `arm`.
  Future<Result<MeasurementSnapshot>> call(MeasurementEntry entry) async {
    // A tape-only reading gets a 422 from the server, so the weight is asked
    // for every time.
    final weight = entry.weightKg;
    if (weight == null) {
      return const Failed(
          ValidationFailure(fieldErrors: {'weight': 'validation.required'}));
    }

    final errors = <String, String>{};
    if (_outside(weight, weightRangeKg)) {
      errors['weight'] = 'validation.outOfRange';
    }
    final circumferences = <String, double?>{
      'waist': entry.waistCm,
      'hip': entry.hipCm,
      'thigh': entry.thighCm,
      'arm': entry.armCm,
    };
    for (final MapEntry(:key, :value) in circumferences.entries) {
      if (value != null && _outside(value, circumferenceRangeCm[key]!)) {
        errors[key] = 'validation.outOfRange';
      }
    }
    if (errors.isNotEmpty) {
      return Failed(ValidationFailure(fieldErrors: errors));
    }
    return _repository.saveEntry(entry);
  }

  static bool _outside(double value, (int, int) range) =>
      value < range.$1 || value > range.$2;
}
