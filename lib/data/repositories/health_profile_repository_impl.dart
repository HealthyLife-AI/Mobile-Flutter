import '../../core/errors/app_exception.dart';
import '../../core/errors/exception_mapper.dart';
import '../../core/errors/result.dart';
import '../../core/logging/app_logger.dart';
import '../../core/storage/patient_cache.dart';
import '../../core/storage/storage_service.dart';
import '../../domain/entities/patient_health_profile_entities.dart';
import '../../domain/repositories/health_profile_repository.dart';
import '../datasources/health_profile_remote_data_source.dart';
import '../models/health_profile_dto.dart';

/// The approved health profile from `GET /me/health-profile` (API guide 11.1).
///
/// The last answer is kept on the device, so the goal, medications and
/// allergies still show without a connection. The copy is cleared at sign-out
/// with the rest of the patient's data (2.5).
class HealthProfileRepositoryImpl
    implements HealthProfileRepository, PatientCache {
  HealthProfileRepositoryImpl(this._storage, this._remote);

  static const DefaultAppLogger _log = DefaultAppLogger();

  final StorageService _storage;
  final HealthProfileRemoteDataSource _remote;

  @override
  Future<Result<PatientHealthProfile>> getProfile() => guard(() async {
        try {
          final raw = await _remote.fetch();
          final profile = HealthProfileDto.fromJson(raw);
          if (profile == null) {
            throw const ParseException(
                'The health profile has an unexpected shape');
          }
          await _remember(raw);
          return profile;
        } on NetworkException {
          // No connection: show the last answer, when there is one.
          final kept = await _remembered();
          if (kept == null) rethrow;
          return kept;
        }
      });

  /// Writes are sent once and never queued or retried. A request sent later,
  /// after the record changed, could be out of date.
  @override
  Future<Result<void>> propose(ChangeRequestDraft draft) => guard(() async {
        await _remote.propose(HealthProfileDto.requestJson(draft));
      });

  @override
  Future<Result<void>> withdraw(int proposalId) => guard(() async {
        await _remote.withdraw(proposalId);
      });

  @override
  Future<void> forgetPatientData() =>
      _storage.remove(StorageKeys.healthProfile);

  Future<PatientHealthProfile?> _remembered() async {
    try {
      final raw = await _storage.readMap(StorageKeys.healthProfile);
      return raw == null ? null : HealthProfileDto.fromJson(raw);
    } on Object catch (error) {
      _log.warn('The kept health profile could not be read', error: error);
      return null;
    }
  }

  /// A failure to keep the copy does not fail a read that succeeded.
  Future<void> _remember(Map<String, dynamic> raw) async {
    try {
      await _storage.writeMap(StorageKeys.healthProfile, raw);
    } on Object catch (error) {
      _log.warn('The health profile could not be kept on this device',
          error: error);
    }
  }
}
