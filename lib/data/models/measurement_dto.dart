import '../../core/errors/app_exception.dart';
import '../../core/sync/pending_write.dart';
import '../../domain/entities/measurement_entities.dart';

/// Maps measurement objects from the API (guide 7.1) and queued `POST` bodies
/// into domain readings.
abstract final class MeasurementDto {
  /// The list answer of `GET /me/measurements`.
  static List<MeasurementEntry> readingsFromJson(Object? raw) {
    if (raw is! List) {
      throw const ParseException('Measurements are not a list');
    }
    final readings = <MeasurementEntry>[];
    for (final item in raw) {
      if (item is! Map<String, dynamic>) {
        throw const ParseException('A reading is not an object');
      }
      readings.add(readingFromJson(item));
    }
    return readings;
  }

  /// One reading object. `recorded_at` is a date, so it is kept as the
  /// patient's local day.
  static MeasurementEntry readingFromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final recorded = json['recorded_at'];
    final date = recorded is String ? DateTime.tryParse(recorded) : null;
    if (id == null || date == null) {
      throw const ParseException('A reading has no id or date');
    }
    return MeasurementEntry(
      id: '$id',
      recordedAt: DateTime(date.year, date.month, date.day),
      source: json['source'] == 'clinic-analyser'
          ? ReadingSource.clinicAnalyser
          : ReadingSource.selfReported,
      weightKg: _number(json['weight_kg']),
      waistCm: _number(json['waist_cm']),
      hipCm: _number(json['hip_cm']),
      thighCm: _number(json['thigh_cm']),
      armCm: _number(json['arm_cm']),
    );
  }

  /// A reading the patient made offline, read back from its queued `POST`
  /// body. It is marked [MeasurementEntry.pending] until the server confirms
  /// it. Null when the body has no date.
  static MeasurementEntry? waitingFromWrite(PendingWrite write) {
    final body = write.body;
    final recorded = body['recorded_at'];
    final date = recorded is String ? DateTime.tryParse(recorded) : null;
    if (date == null) return null;
    return MeasurementEntry(
      id: 'waiting-${write.id}',
      recordedAt: DateTime(date.year, date.month, date.day),
      source: ReadingSource.selfReported,
      pending: true,
      weightKg: _number(body['weight_kg']),
      waistCm: _number(body['waist_cm']),
      hipCm: _number(body['hip_cm']),
      thighCm: _number(body['thigh_cm']),
      armCm: _number(body['arm_cm']),
    );
  }

  static double? _number(Object? value) =>
      value is num ? value.toDouble() : null;
}
