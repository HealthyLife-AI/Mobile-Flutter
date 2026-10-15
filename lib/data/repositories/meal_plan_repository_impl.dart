import '../../core/errors/app_exception.dart';
import '../../core/errors/exception_mapper.dart';
import '../../core/errors/result.dart';
import '../../core/logging/app_logger.dart';
import '../../core/storage/patient_cache.dart';
import '../../core/storage/storage_service.dart';
import '../../domain/entities/meal_plan_entities.dart';
import '../../domain/repositories/meal_plan_repository.dart';
import '../datasources/meal_plan_data_source.dart';
import '../models/meal_plan_dto.dart';

/// The active plan from `GET /me/meal-plan` (API guide 5.1), exactly as the
/// nutritionist set it.
///
/// The last answer is kept on the device, so the plan still shows without a
/// connection. "No active plan" (204) forgets the kept copy, so a deactivated
/// plan never lingers. The copy is cleared at sign-out with the rest of the
/// patient's data (2.5).
class MealPlanRepositoryImpl implements MealPlanRepository, PatientCache {
  MealPlanRepositoryImpl(this._storage, this._remote);

  static const DefaultAppLogger _log = DefaultAppLogger();

  final StorageService _storage;
  final MealPlanRemoteDataSource _remote;

  @override
  Future<Result<MealPlan?>> getActivePlan() => guard(() async {
        try {
          final raw = await _remote.fetchActivePlan();
          if (raw == null) {
            await _forget();
            return null;
          }
          final plan = MealPlanDto.fromJson(raw);
          if (plan == null) {
            throw const ParseException('The meal plan has an unexpected shape');
          }
          await _remember(raw);
          return plan;
        } on NetworkException {
          // No connection: show the last plan read, when there is one.
          final kept = await _remembered();
          if (kept == null) rethrow;
          return kept;
        }
      }, context: 'MealPlanRepository.getActivePlan');

  @override
  Future<void> forgetPatientData() => _forget();

  Future<void> _forget() => _storage.remove(StorageKeys.mealPlan);

  Future<MealPlan?> _remembered() async {
    try {
      final raw = await _storage.readMap(StorageKeys.mealPlan);
      return raw == null ? null : MealPlanDto.fromJson(raw);
    } on Object catch (error) {
      _log.warn('The kept meal plan could not be read', error: error);
      return null;
    }
  }

  /// A failure to keep the copy does not fail a read that succeeded.
  Future<void> _remember(Map<String, dynamic> raw) async {
    try {
      await _storage.writeMap(StorageKeys.mealPlan, raw);
    } on Object catch (error) {
      _log.warn('The meal plan could not be kept on this device', error: error);
    }
  }
}
