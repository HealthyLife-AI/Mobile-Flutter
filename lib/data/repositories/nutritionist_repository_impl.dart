import '../../core/errors/app_exception.dart';
import '../../core/errors/exception_mapper.dart';
import '../../core/errors/result.dart';
import '../../core/logging/app_logger.dart';
import '../../core/storage/patient_cache.dart';
import '../../core/storage/storage_service.dart';
import '../../domain/entities/nutritionist_entities.dart';
import '../../domain/repositories/nutritionist_repository.dart';
import '../datasources/nutritionist_remote_data_source.dart';
import '../models/nutritionist_dto.dart';

/// The patient's nutritionist from `GET /me/nutritionist` (API guide 9.1).
///
/// The last answer is kept on the device, so the profile still shows without a
/// connection. The copy is cleared at sign-out with the rest of the patient's
/// data (2.5).
class NutritionistRepositoryImpl
    implements NutritionistRepository, PatientCache {
  NutritionistRepositoryImpl(this._storage, this._remote);

  static const DefaultAppLogger _log = DefaultAppLogger();

  final StorageService _storage;
  final NutritionistRemoteDataSource _remote;

  @override
  Future<Result<NutritionistProfile>> getProfile() => guard(() async {
        try {
          final profile = await _remote.fetch();
          await _remember(profile);
          return profile;
        } on NetworkException {
          // No connection: show the last answer, when there is one.
          final kept = await _remembered();
          if (kept == null) rethrow;
          return kept;
        }
      });

  @override
  Future<void> forgetPatientData() => _storage.remove(StorageKeys.nutritionist);

  Future<NutritionistProfile?> _remembered() async {
    try {
      final raw = await _storage.readMap(StorageKeys.nutritionist);
      return raw == null ? null : NutritionistDto.fromJson(raw);
    } on Object catch (error) {
      _log.warn('The kept nutritionist could not be read', error: error);
      return null;
    }
  }

  /// A failure to keep the copy does not fail a read that succeeded.
  Future<void> _remember(NutritionistProfile profile) async {
    try {
      await _storage.writeMap(
          StorageKeys.nutritionist, NutritionistDto.toJson(profile));
    } on Object catch (error) {
      _log.warn('The nutritionist could not be kept on this device',
          error: error);
    }
  }
}
